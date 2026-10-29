import com.android.build.gradle.AppExtension

val android = project.extensions.getByType(AppExtension::class.java)

android.apply {
    flavorDimensions("flavor-type")

    productFlavors {
        create("development") {
            dimension = "flavor-type"
            applicationId = "com.apps.pikoelan_nusantara_dev"
            resValue(type = "string", name = "app_name", value = "[DEV] Pikoelan Nusantara")
        }
        create("production") {
            dimension = "flavor-type"
            applicationId = "com.apps.pikoelan_nusantara"
            resValue(type = "string", name = "app_name", value = "Pikoelan Nusantara")
        }
    }

    buildFeatures.resValues = true
}