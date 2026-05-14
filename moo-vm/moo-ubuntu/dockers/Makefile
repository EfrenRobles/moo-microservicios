# ============================================================
# Plataforma de desarrollo local - Makefile
# Autor: Efren v3.0.0
# ============================================================

# Contenedores
LOCALSTACK_CONTAINER=localstack
OPENLDAP_CONTAINER=openldap-adlike

#Configuraciones de LDAP
LDAP_BASE_DN=dc=example,dc=com
LDAP_BIND_DN=cn=admin,$(LDAP_BASE_DN)
LDAP_PASSWORD=admin

# Configuraciones de SQS SQS
SQS_URL=http://sqs.us-east-1.localhost.localstack.cloud:4566/000000000000/my-queue

# ============================================================
# Instrucciones
#
# Nota: La sangria debe de ir con tabuladores, si pones espacioes tronara.
# ============================================================

# Inicia todos los servicios
up:
	docker compose up -d
	@echo "Arrancando todos los servicios"
	docker exec -it $(LOCALSTACK_CONTAINER) bash /localstack/init-localstack.sh

# Detiene todos los servicios
down:
	docker compose down
	@echo "Deteniendo todos los servicios"

# ============================================================
# LocalStack (SQS)
# ============================================================

# Lista de SQS queues
sqs-list:
	docker exec -it $(LOCALSTACK_CONTAINER) awslocal sqs list-queues

# ============================================================
# OpenLDAP
# ============================================================

# Para consultar a un usuario en especifico por samAccountName
# Uso: make ldap-query-user UID=ediaz16
ldap-query-user:
ifndef UID
	@echo "Uso: make ldap-query-user UID=someuid"
	@exit 1
endif
	docker exec -it $(OPENLDAP_CONTAINER) \
		ldapsearch -x -H ldap://localhost:389 \
		-D "$(LDAP_BIND_DN)" -w $(LDAP_PASSWORD) \
		-b "ou=Users,$(LDAP_BASE_DN)" "(samAccountName=$(UID))"

# Consultar a todos los usuarios
ldap-users:
	docker exec -it $(OPENLDAP_CONTAINER) \
		ldapsearch -x -H ldap://localhost:389 \
		-D "$(LDAP_BIND_DN)" -w $(LDAP_PASSWORD) \
		-b "ou=Users,$(LDAP_BASE_DN)" "(objectClass=user)"

# Consultar a todos los Groups
ldap-groups:
	docker exec -it $(OPENLDAP_CONTAINER) \
		ldapsearch -x -H ldap://localhost:389 \
		-D "$(LDAP_BIND_DN)" -w $(LDAP_PASSWORD) \
		-b "ou=Groups,$(LDAP_BASE_DN)" "(objectClass=groupOfNames)"

# Consultar a todos los Roles
ldap-roles:
	docker exec -it $(OPENLDAP_CONTAINER) \
		ldapsearch -x -H ldap://localhost:389 \
		-D "$(LDAP_BIND_DN)" -w $(LDAP_PASSWORD) \
		-b "ou=Roles,$(LDAP_BASE_DN)" "(objectClass=groupOfNames)"

# Consultar todos los scopes
ldap-scopes:
	docker exec -it $(OPENLDAP_CONTAINER) \
		ldapsearch -x -H ldap://localhost:389 \
		-D "$(LDAP_BIND_DN)" -w $(LDAP_PASSWORD) \
		-b "ou=Scopes,$(LDAP_BASE_DN)" "(objectClass=groupOfNames)"

# Muestra el memberOf de un usuario en especifico
# Usage: make ldap-memberof UID=ediaz16
ldap-memberof:
ifndef UID
	@echo "Usage: make ldap-memberof UID=someuid"
	@exit 1
endif
	docker exec -it $(OPENLDAP_CONTAINER) \
		ldapsearch -x -H ldap://localhost:389 \
		-D "$(LDAP_BIND_DN)" -w $(LDAP_PASSWORD) \
		-b "ou=Users,$(LDAP_BASE_DN)" "(samAccountName=$(UID))" memberOf

# ============================================================
# Lista de instrucciones
# ============================================================

help:
	@echo ""
	@echo "Instrucciones Makefile para desarrollo local"
	@echo ""
	@echo "  make up                      - Inicia todos los servicios"
	@echo "  make down                    - Detiene todos los servicios"
	@echo ""
	@echo "  make sqs-list                - Lista los SQS queues"
	@echo ""
	@echo "  make ldap-query-user UID=uid - Consultar a un usuario en especifico por samAccountName"
	@echo "  make ldap-users              - Lista todos los LDAP users"
	@echo "  make ldap-groups             - Lista todos los LDAP groups"
	@echo "  make ldap-roles              - Lista todos los LDAP roles"
	@echo "  make ldap-scopes             - Lista todos los LDAP scopes"
	@echo "  make ldap-memberof UID=uid   - Muestra el memberOf de un usuario en especifico"
	@echo ""
