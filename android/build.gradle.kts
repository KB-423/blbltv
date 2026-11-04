allprojects {
    repositories {
        // 阿里云 Google 镜像，对应 google()
        maven("https://maven.aliyun.com/repository/google")
        // 阿里云公共镜像，对应 mavenCentral()
        maven("https://maven.aliyun.com/repository/public")
        // google()
        // mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
