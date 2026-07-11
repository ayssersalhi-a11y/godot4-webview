use godot::prelude::*;
use jni::objects::{JClass, JObject};
use jni::JNIEnv;
use std::sync::Mutex;
use lazy_static::lazy_static;

lazy_static! {
    static ref ANDROID_ACTIVITY: Mutex<Option<JObject<'static>>> = Mutex::new(None);
}

#[no_mangle]
pub extern "system" fn Java_org_godotengine_godot_GodotLib_initWebView(
    mut env: JNIEnv,
    _class: JClass,
    activity: JObject,
) {
    godot_print!("Android WebView: Activity received!");
    
    if let Ok(global_ref) = env.new_global_ref(activity) {
        let mut activity_store = ANDROID_ACTIVITY.lock().unwrap();
        
        // التعديل هنا: استخدمنا clone() للحصول على نسخة من الـ JObject 
        // لتتوافق مع النوع المتوقع في الـ Option
        *activity_store = Some(global_ref.as_obj().clone());
        godot_print!("Android WebView: Activity stored successfully.");
    }
}

pub fn get_android_activity() -> Option<JObject<'static>> {
    let activity_store = ANDROID_ACTIVITY.lock().unwrap();
    
    // التعديل هنا: لا يمكننا "سحب" القيمة مباشرة من الـ Mutex (لأنها ليست Copy)
    // لذا نقوم بعمل clone للـ Option (التي تحتوي على الـ JObject)
    activity_store.clone()
}

pub fn init_android_webview() {
    godot_print!("Android WebView system initialized and ready to bridge.");
}
