plugins {
    java
    // Este plugin ayuda a gestionar versiones de forma global
    id("org.springframework.boot") version Versions.springBoot apply false
    id("io.spring.dependency-management") version "1.1.7" apply false
}

allprojects {
    group = "com.moo"
    version = "0.0.1"

    repositories {
        mavenCentral()
    }
}

subprojects {
    apply(plugin = "java")
    
    java {
        toolchain {
            languageVersion.set(JavaLanguageVersion.of(Versions.java))
        }
    }
}