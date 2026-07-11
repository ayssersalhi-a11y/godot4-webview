use godot::prelude::*;
use jni::objects::{JClass, JObject, GlobalRef};
use jni::JNIEnv;
use std::sync::Mutex;
use lazy_static::lazy_static;

lazy_static! {
    // نخزن GlobalRef لأنها قابلة للمشاركة والنسخ بأمان داخل الـ Mutex
    static ref ANDROID_ACTIVITY: Mutex<Option<GlobalRef>> = Mutex::new(None);
}

#[no_mangle]
pub extern "system" fn Java_org_godotengine_godot_GodotLib_initWebView(
    env: JNIEnv,
    _class: JClass,
    activity: JObject,
) {
    godot_print!("Android WebView: Activity received!");
    
    // تحويل الـ activity إلى GlobalRef لضمان بقائها في الذاكرة
    if let Ok(global_ref) = env.new_global_ref(activity) {
        let mut activity_store = ANDROID_ACTIVITY.lock().unwrap();
        *activity_store = Some(global_ref);
        godot_print!("Android WebView: Activity stored successfully.");
    }
}

pub fn get_android_activity() -> Option<JObject<'static>> {
    let activity_store = ANDROID_ACTIVITY.lock().unwrap();
    
    // نقوم بفك الـ Option والوصول إلى الـ GlobalRef
    // ثم نرجع الـ JObject الخاص بها
    if let Some(global_ref) = &*activity_store {
        Some(global_ref.as_obj())
    } else {
        None
    }
}

pub fn init_android_webview() {
    godot_print!("Android WebView system initialized and ready to bridge.");
}
