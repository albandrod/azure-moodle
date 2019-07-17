# Readme #

Hi ha **dues** maneres de llençar el deployment amb aquesta plantilla: amb l'script de desplegament o via el portal d'Azure.
És molt important que el desplegament es faci seguint aquestes instruccions, doncs els scripts de configuració de les màquines han d'estar disponibles (però no públics) per a poder tornar a desplegar-los si cal fer modificacions a les màquines virtuals.

## Script de desplegament ##

L'script de desplegament (deploy.sh) fa servir les comandes d'Azure CLI per fer el desplegament.
Concretament, l'script fa el següent:

  - Crea un grup de recursos amb un compte d'emmagatzematge.
  - Demana una clau SAS per poder accedir als recursos via URL.
  - Modifica els fitxers de configuració amb la ruta de l'espai d'emmagatzematge.
  - Copia els scripts a l'espai d'emmagatzematge.
  - Desplega l'ARM fent servir la ruta dels scripts emmagatzemats.

Per utilitzar l'script cal:

  - Crear una carpeta env i crear un fitxer fent servir el fitxer env-dist.sh com a base.
  - Omplir el fitxer de variables creat anteriorment amb la configuració del desplegament.
  - Cridar l'script passant el fitxer de variables com a primer paràmetre
    - Exemple: ./deploy.sh env/env-PRE.sh
  - A l'script se li pot passar un tercer paràmetre addicional --debug o --verbose per debugar.

Requeriments per utilitzar l'script:

  - Bash
  - Llibreria jq
  - Llibreria azure-cli

## Desplegament via portal Azure ##

Per desplegar via el portal, cal:

  - Crear un espai d'emmagatzematge i pujar-hi el contingut del repositori.
  - Obtenir la clau SAS per poder accedir als recursos via URL.
  - Realitzar un desplegament mitjançant plantilla fent servir el azuredeploy-XXX.json corresponent.
  - Cal omplir els tres camps de paràmetre que demana la plantilla:
    - \_artifactsLocation: adreça de l'espai d'emmagatzematge obtinguda de la petició de clau SAS (amb /scripts/)
    - \_artifactsLocationSasToken: token de l'espai d'emmagatzematge obtinguda de la petició de clau SAS
    - \_sshPublicKey: clau pública de l'SSH

## Opcions a configurar després del desplegament ##

Un cop fet el desplegament, cal configurar les opcions següents:

  - MySQL
    - Server parameters
      - INNODB_FILE_PER_TABLE = ON
    - Plan de tarifa
      - Crecimiento automático = Sí