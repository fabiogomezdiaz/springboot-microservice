workspace(name = "springboot_microservice")

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

# Update these values with the specific version and SHA you wish to use
http_archive(
    name = "rules_jvm_external",
    sha256 = "6cc8444b20307113a62b676846c29ff018402fd4c7097fcd6d0a0fd5f2e86429",
    strip_prefix = "rules_jvm_external-5.3",
    url = "https://github.com/bazelbuild/rules_jvm_external/archive/5.3.zip",
)

load("@rules_jvm_external//:defs.bzl", "maven_install")

maven_install(
    artifacts = [
        "org.springframework.boot:spring-boot-starter-actuator:2.7.3",
        "org.springframework.boot:spring-boot-starter-web:2.7.3",
        "org.projectlombok:lombok:1.18.24",
        "org.springframework.boot:spring-boot-starter-test:2.7.3",
    ],
    repositories = [
        "https://repo1.maven.org/maven2",
    ],
)
