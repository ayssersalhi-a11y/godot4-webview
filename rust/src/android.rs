use godot::prelude::*;
use jni::objects::{JClass, JObject, GlobalRef};
use jni::JNIEnv;
use std::sync::Mutex;
use lazy_static::lazy_static;

lazy_static! {
    // نغير النوع ليخزن GlobalRef بدلاً من JObject
    // لأن GlobalRef قابلة للنسخ (Cloneable) وهذا ضروري للـ Mutex
    static ref ANDROID_ACTIVITY: Mutex<Option<GlobalRef>> = Mutex::new(None);
}

#[no_mangle]
pub extern "system" fn Java_org_godotengine_godot_GodotLib_initWebView(
    mut env: JNIEnv,
    _class: JClass,
    activity: JObject,
) {
    godot_print!("Android WebView: Activity received!");
    
    // نقوم بإنشاء GlobalRef لضمان بقاء الكائن في الذاكرة
    if let Ok(global_ref) = env.new_global_ref(activity) {
        let mut activity_store = ANDROID_ACTIVITY.lock().unwrap();
        
        // الآن نخزن الـ GlobalRef مباشرة
        *activity_store = Some(global_ref);
        godot_print!("Android WebView: Activity stored successfully.");
    }
}

pub fn get_android_activity() -> Option<JObject<'static>> {
    let activity_store = ANDROID_ACTIVITY.lock().unwrap();
    
    // نستخدم as_ref().map() لاستخراج الـ JObject من الـ GlobalRef الموجود داخل الـ Option
    // هذا لا ينقل الملكية، بل يعطينا مرجعاً للكائن
    activity_store.as_ref().map(|g| g.as_obj())
}

pub fn init_android_webview() {
    godot_print!("Android WebView system initialized and ready to bridge.");
}
