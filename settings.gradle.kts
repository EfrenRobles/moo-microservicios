rootProject.name = "moo-workspace"

// Definimos los grupos de módulos
val commons = listOf("api", "jpa", "feign", "logging")
val auth = listOf("api", "service", "client")
val users = listOf("api", "service", "client")

// Registro dinámico para mantener el archivo limpio
commons.forEach { include("moo-commons:moo-commons-$it") }
auth.forEach { include("moo-auth:moo-auth-$it") }
users.forEach { include("moo-users:moo-users-$it") }

include("moo-gateway")