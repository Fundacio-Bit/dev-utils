# dev-utils

Configuració d'entorn i eines de línia de comandes per al desenvolupament en R. Rscript, Openjdk i maven.

## Inici

Aquestes instruccions t'ajudaran a obtenir una còpia del projecte en funcionament al teu ordinador per al desenvolupament i les proves. Consulta la secció de desplegament per obtenir notes sobre com desplegar el projecte en un sistema en producció.


### Requisits previs

* Sistema operatiu Ubuntu, Debian o CentOS
* Un compte d'usuari amb privilegis de sudo
* Línia de comandes/terminal (CTRL-ALT-T o Menú d'aplicacions > Accessoris > Terminal)

### Instal·lació
---

Clona aquest repositori al teu ordinador.

```bash
git clone https://github.com/Fundacio-Bit/dev-utils.git

# Es recomana bifurcar aquest repositori per a aplicacions específiques
```

## Configuració de valors d'entorn
---

Els valors d'entorn estàn preconfigurats. Consulta la carpeta ./settings.template.d.


### Generar valors locals de configuració des de la plantilla
---

1. Executa l'script [bin/app_settings.sh](./bin/app_settings.sh) per crear la carpeta de configuració i copiar-hi els fitxers de plantilla. Si ja existeix una versió prèvia, aquesta es farà una còpia de seguretat.

    ```bash
    bin/app_settings.sh
    ```

2. Opcionalment, executa [bin/app_clearenvbackup.sh](./bin/app_clearenvbackup.sh) per esborrar fitxers de seguretat anteriors a la carpeta de configuració.

     ```bash
    bin/app_clearenvbackup.sh
    ```

3. Defineix el nom de l'aplicació executant [bin/app_setappname.sh] (bin/app_setappname.sh). Defineix els paràmetres "codapp" i "app" com a nom llarg i nom curt de l'aplicació, respectivament.

    ```bash
    # bin/app_setappname.sh --codapp=long-application-name --app=shortapplicationname
    bin/app_setappname.sh --codapp=main --app=main

    ```
    Repeteix aquest pas cada vegada que s'executi "app_settings". En cas contrari, el nom de l'aplicació tindrà valors predeterminats.

### Actualitzar els valors de configuració de l'arxiu .env
---

Un cop hagis actualitzat els fitxers locals:

1. Executa [bin/app_setenv.sh](./bin/app_setenv.sh) per crear un fitxer .env i que els valors configurats a la carpeta de configuració entrin en vigor.
    
    ```bash
    bin/app_setenv.sh
    ```

2. Executa [bin/app_setenv_all.sh](./bin/app_setenv_all.sh) per crear un fitxer .env i que els valors configurats a la carpeta de configuració entrin en vigor.
    
    ```bash
    bin/app_setenv_all.sh
    ```



3. No és necessari executar "bin/lib_xxx_utils.sh" directament. Aquests scripts s'inclouen des d'altres per llegir i exportar valors del fitxer .env, i s'han d'actualitzar amb cura. Els scripts inclosos són:
    * [bin/lib_env_utils.sh](bin/lib_env_utils.sh)
    * [bin/lib_string_utils.sh](bin/lib_string_utils.sh)


### Contingut detallat dels fitxers de configuració
---

* Els valors en format ${some_value} estan preconfigurats.
* Totes les variables en un fitxer tenen un prefix distintiu, excepte els fitxers 200_jdk, 300_mvn i 400_jboss.

1. Edita el fitxer [./settings/100_app](./settings.template.d/100_app.template) i comprova els valors de les variables, com es mostra:

    ```bash
    LONG_APP_NAME=long-app-name
    SHORT_APP_NAME=short-app-name
    ```


2. Edita el fitxer [./settings/200_jdk](./settings.template.d/200_jdk.template). Aquests valors estableixen el directori Java Home i l'objectiu d'instal·lació per defecte. **L'àmbit de l'entorn és local al teu script.**

    Per defecte, la versió del JDK és l'11. Consulta [./settings.template.d/200_jdk.template](./settings.template.d/200_jdk.template) per veure alguns exemples de descàrrega d'altres versions. També, l'objectiu per defecte es troba al directori del projecte.

    ```bash
    JDK_BASE_PATH=${APP_PROJECT_PATH}/java

    JDK11_BASEURL=https://download.java.net/java/ga/jdk11/
    JDK11_LINUX_FILE=openjdk-11_linux-x64_bin.tar.gz
    JDK11_WINDOWS_FILE=openjdk-11_windows-x64_bin.zip
    JDK11_TARGET=${JDK_BASE_PATH}/${APP_NAME}
    ```
    
    Consulta [bin/jdk_jdkinstall.sh](bin/jdk_jdkinstall.sh) per a la instal·lació del JDK.
    Accés directe a [Instal·lació d'eines Java](#installing-java-tools) si es necessita més detall.


3. Edita el fitxer [./settings/900_custom](./settings.template.d/900_custom.template).

    Aquests valors configuren qualsevol valor personalitzat no inclòs prèviament en altres fitxers, com ara el PATH. **L'àmbit de l'entorn és local al teu script.**

    ```bash
    # Secció personalitzada
    # Utilitza aquest fitxer per a configuracions personalitzades de l'aplicació

    # Fi de la secció personalitzada

    # Secció d'actualització del PATH
    PATH=$JAVA_HOME/bin:$M2_HOME/bin:$PATH
    # Fi de la secció d'actualització del PATH
    ```

    **Els valors reals podrien ser diferents als anteriors un cop els fitxers a la carpeta de configuració hagin estat editats. Pren aquests exemples com a referència.**

4. Els valors preconfigurats es guarden a la carpeta de configuració i es poden utilitzar *tal com estan* o modificar localment segons el teu criteri. Tot i que és possible configurar qualsevol tipus de paràmetre, mai no s'han d'establir contrasenyes a la carpeta settings.template.d. *Tots els canvis es commetran al repositori.* Sempre configura dades crítiques a la carpeta local de configuració i estableix permisos si és necessari.




## Execució

---

1. Clona aquest repositori al teu ordinador si encara no ho has fet.

    ```bash
    git clone https://github.com/Fundacio-Bit/dev-utils.git
    ```


2. Comprova els valors preconfigurats i canvia'ls com s'ha explicat anteriorment si és necessari.


3. Executa l'script [app_setenv](./bin/app_setenv.sh). Genera un fitxer .env a partir del contingut de la carpeta de configuració per ubicar-lo a la carpeta principal. Quan es carreguin les variables d'entorn, aquest fitxer s'utilitzarà com a entrada. Repeteix els passos 2 i 3 tantes vegades com sigui necessari.

    ```bash
    ./bin/app.setenv.sh
    ```
    **Recorda executar-ho després d'editar la configuració. En cas contrari, el fitxer .env romandrà sense modificar.**

### Instal·lació d'eines Java

---

1. Opcionalment, executa l'script [jdkinstall](./bin/jdk_jdkinstall.sh). Aquest descarrega un fitxer tar.gz i l'infla a l'objectiu preconfigurat. Consulta el fitxer ./settings/200_jdk. Si la versió del JDK és inferior a la 9, la plataforma del JDK s'haurà d'instal·lar manualment.

    ```bash
    ./bin/jdk_jdkinstall.sh
    ```


---
## Autors

* **gdeignacio**  - [gdeignacio](https://github.com/gdeignacio)

## Llicència

Aquest projecte està llicenciat sota la Llicència MIT - consulta el fitxer [LICENSE](LICENSE) per a més detalls.

## Agraïments

