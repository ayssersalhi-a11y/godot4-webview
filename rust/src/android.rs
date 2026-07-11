use godot::prelude::*;
use jni::objects::{JClass, JObject, GlobalRef};
use jni::JNIEnv;
use std::sync::Mutex;
use lazy_static::lazy_static;

lazy_static! {
    static ref ANDROID_ACTIVITY: Mutex<Option<GlobalRef>> = Mutex::new(None);
}

#[no_mangle]
pub extern "system" fn Java_org_godotengine_godot_GodotLib_initWebView(
    env: JNIEnv,
    _class: JClass,
    activity: JObject,
) {
    godot_print!("Android WebView: Activity received!");
    
    if let Ok(global_ref) = env.new_global_ref(activity) {
        let mut activity_store = ANDROID_ACTIVITY.lock().unwrap();
        *activity_store = Some(global_ref);
        godot_print!("Android WebView: Activity stored successfully.");
    }
}

pub fn get_android_activity() -> Option<JObject<'static>> {
    let activity_store = ANDROID_ACTIVITY.lock().unwrap();
    
    // الحل: نقوم بعمل clone للـ GlobalRef أولاً (وهو مسموح)، 
    // ثم نستخرج منها الـ JObject. بهذا نضمن أننا نرجع JObject مملوكاً وليس مرجعاً.
    activity_store.clone().map(|g| g.as_obj())
}

pub fn init_android_webview() {
    godot_print!("Android WebView system initialized and ready to bridge.");
}
