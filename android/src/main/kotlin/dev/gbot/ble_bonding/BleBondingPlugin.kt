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
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** BleBondingPlugin */
class BleBondingPlugin: FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private lateinit var mBluetoothAdapter: BluetoothAdapter
  private lateinit var applicationContext: Context
  val channelResultForAddress = LinkedHashMap<String, Result>()

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "ble_bonding")
    channel.setMethodCallHandler(this)

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
    if (call.method == "getPlatformVersion") {
      result.success("Android ${android.os.Build.VERSION.RELEASE}")
    } else if (call.method == "bond") {
      val address = call.argument<String>("address") ?: return
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
    } else {
      result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  private val bondStateReceiver: BroadcastReceiver = object : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
      val action: String? = intent.getAction()
      if (action.equals(BluetoothDevice.ACTION_BOND_STATE_CHANGED)) {
        when (intent.getIntExtra(BluetoothDevice.EXTRA_BOND_STATE, BluetoothDevice.ERROR)) {
          BluetoothDevice.BOND_BONDED -> {
            //setBonded(true)
            println("BtleConManager bonded lets make a connection")
            val device: BluetoothDevice? = intent.getParcelableExtra<BluetoothDevice>(
              BluetoothDevice.EXTRA_DEVICE
            )
            val address = device?.address
            val result = channelResultForAddress[address]

            if (result == null) {
              println("Received intent for unexpected device $address")
            } else {
              result.success(null)
            }
          }
          BluetoothDevice.BOND_BONDING -> println("BtleConManager bonding")
          BluetoothDevice.BOND_NONE -> {
            println("BtleConManager unbonded")
            //setBonded(false)
            val prevState: Int = intent.getIntExtra(
              BluetoothDevice.EXTRA_PREVIOUS_BOND_STATE,
              BluetoothDevice.ERROR
            )
            if (prevState == BluetoothDevice.BOND_BONDING) {
              //
            }
          }
        }
      }
    }
  }
}
