package dev.gbot.ble_bonding

import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Build
import androidx.annotation.NonNull
import androidx.annotation.RequiresApi

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.EventSink
import io.flutter.plugin.common.EventChannel.StreamHandler
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.lang.reflect.Method

/** BleBondingPlugin */
class BleBondingPlugin: FlutterPlugin, MethodCallHandler {
  private lateinit var channel : MethodChannel
  private lateinit var eventChannel: EventChannel
  private lateinit var mBluetoothAdapter: BluetoothAdapter
  private lateinit var applicationContext: Context
  val channelResultForAddress = LinkedHashMap<String, Result>()
  val eventSinksForAddress = LinkedHashMap<String, MutableList<EventSink>>()

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "ble_bonding")
    channel.setMethodCallHandler(this)

    eventChannel = EventChannel(flutterPluginBinding.binaryMessenger, "ble_bonding_state_stream")
    eventChannel.setStreamHandler(stateStreamHandler)

    applicationContext = flutterPluginBinding.applicationContext

    mBluetoothAdapter = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR2) {
      flutterPluginBinding.applicationContext.getSystemService(BluetoothManager::class.java).adapter
    } else {
      BluetoothAdapter.getDefaultAdapter()
    };

    applicationContext.registerReceiver(
      bondStateReceiver,
      IntentFilter(BluetoothDevice.ACTION_BOND_STATE_CHANGED)
    )
  }

  @RequiresApi(Build.VERSION_CODES.KITKAT)
  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    if (call.method == "bond") {
      val address = getMaybeAddressFromArgs(call, result) ?: return
      val device = mBluetoothAdapter.getRemoteDevice(address)
      val started = device.createBond()

      if (!started) {
        result.error("Bond could not start", null, null)
        return
      }

      if (channelResultForAddress.containsKey(address)) {
        channelResultForAddress[address]?.error("New request came in", null, null)
      }

      channelResultForAddress[address] = result
    } else if (call.method == "getBondingState") {
      val address = getMaybeAddressFromArgs(call, result) ?: return

      val device = mBluetoothAdapter.getRemoteDevice(address)

      result.success(device.bondState)
    } else if (call.method == "unbound") {
        val address = getMaybeAddressFromArgs(call, result) ?: return

        val device = mBluetoothAdapter.getRemoteDevice(address)

        try {
          device::class.java.getMethod("removeBond").invoke(device)
          result.success(null)
        } catch (e: Exception) {
          println("Removing bond failed: ${e.message}")
          result.error("Removing bond failed", null, null);
        }

    } else {
      result.notImplemented()
    }
  }

  private fun getMaybeAddressFromArgs(
      call: MethodCall,
      result: Result
  ): String? {
    val address = call.argument<String>("address")
    if (address == null) {
      result.error("Invalid address", null, null)
    }
    return address
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  private val bondStateReceiver: BroadcastReceiver = object : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
      val action = intent.action
      if (action.equals(BluetoothDevice.ACTION_BOND_STATE_CHANGED)) {
        val device: BluetoothDevice? = intent.getParcelableExtra<BluetoothDevice>(
          BluetoothDevice.EXTRA_DEVICE
        )
        val address = device?.address

        val state = intent.getIntExtra(BluetoothDevice.EXTRA_BOND_STATE, BluetoothDevice.ERROR)

        eventSinksForAddress[address]?.forEach {
          it.success(state)
        }

        when (state) {
          BluetoothDevice.BOND_BONDED -> {
            print("bonded")
            val channelResult = channelResultForAddress[address]

            if (channelResult == null) {
              println("Received intent for unexpected device $address")
            } else {
              channelResult.success(null)
              channelResultForAddress.remove(address)
            }
          }
          BluetoothDevice.BOND_BONDING -> println("bonding")
          BluetoothDevice.BOND_NONE -> {
            println("none")
            val prevState: Int = intent.getIntExtra(
              BluetoothDevice.EXTRA_PREVIOUS_BOND_STATE,
              BluetoothDevice.ERROR
            )
            if (prevState == BluetoothDevice.BOND_BONDING) {
              print("tried and failed")
            }

            eventSinksForAddress.remove(address)
          }
        }
      }
    }
  }

  private val stateStreamHandler: StreamHandler = object: StreamHandler {
    override fun onListen(arg: Any?, stateEventSink: EventSink) {
      val argMap = arg as? Map<*, *>

      if (argMap != null) {
        val address = argMap["address"]
        if (address is String) {
          val sinks = eventSinksForAddress[address] ?: mutableListOf<EventSink>()
          sinks.add(stateEventSink)
          eventSinksForAddress[address] = sinks
        } else {
          stateEventSink.error("Address must be a String", null, null)
        }
      } else {
        stateEventSink.error("Address is not found", null, null)
      }

    }

    override fun onCancel(arg: Any) {
      val argMap = arg as? Map<*, *>

      if (argMap != null) {
        val address = argMap["address"]
        if (address is String) {
          val sinks = eventSinksForAddress[address] ?: mutableListOf<EventSink>()
          // how can you differentiate, they all have the same address...
          // so, multiple streams listening to it are cleared together here
          sinks.clear()
          eventSinksForAddress[address] = sinks;
        }
      }
    }
  }



}
