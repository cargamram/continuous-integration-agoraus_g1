# Agora@US Continuous Integration

Repositorio de integración continua para AgoraUS-G1 (mañana) en el curso 2016-17. Más información en https://1984.lsi.us.es/wiki-egc/index.php/Servidor_16/17

# Proyectos Integrados

Proyecto | Beta | Stable
------------ | ------------- | -------------
[Deliberations](https://github.com/AgoraUS-G1-1617/Deliberations) | [beta.deliberaciones...](https://beta.deliberaciones.agoraus1.egc.duckdns.org) | [deliberaciones...](https://deliberaciones.agoraus1.egc.duckdns.org)
[Cabina-de-votaciones](https://github.com/AgoraUS-G1-1617/Cabina-de-votaciones) | [beta.cvotacion...](https://beta.cvotacion.agoraus1.egc.duckdns.org) | [cvotacion...](https://cvotacion.agoraus1.egc.duckdns.org)
[CabinaTelegram](https://github.com/AgoraUS-G1-1617/CabinaTelegram) | [@CabinaEGCDevBot](https://telegram.me/CabinaEGCDevBot) | [@CabinaEGCBot](https://telegram.me/CabinaEGCBot)
[Frontend](https://github.com/AgoraUS-G1-1617/Frontend) | [beta.frontend...](https://beta.frontend.agoraus1.egc.duckdns.org/) | [frontend...](https://frontend.agoraus1.egc.duckdns.org/)
[Creacion-Admin-Votaciones](https://github.com/AgoraUS-G1-1617/Creacion-admin-de-votaciones) | [beta.cavotacion...](https://beta.cavotacion.agoraus1.egc.duckdns.org/) | [cavotacion...](https://cavotacion.agoraus1.egc.duckdns.org/)
[Censos](https://github.com/AgoraUS-G1-1617/CensoEGC) | [beta.censos...](https://beta.censos.agoraus1.egc.duckdns.org/) | [censos...](https://censos.agoraus1.egc.duckdns.org)
[Recuento y Modificación](https://github.com/AgoraUS-G1-1617/Recuento-y-modificacion) | [beta.recuento...](https://beta.recuento.agoraus1.egc.duckdns.org/) | [recuento...](https://recuento.agoraus1.egc.duckdns.org)
[Autenticación_b](https://github.com/AgoraUS-G1-1617/Autenticacion_b) | [beta.authb...](https://beta.authb.agoraus1.egc.duckdns.org/) | [authb...](https://authb.agoraus1.egc.duckdns.org)
[Autenticación_a](https://github.com/AgoraUS-G1-1617/Autentication) | [beta.autha...](https://beta.autha.agoraus1.egc.duckdns.org/) | [autha...](https://autha.agoraus1.egc.duckdns.org/)



# ¿Como integro mi proyecto?

[Aquí](documentation/presentation.pdf) puedes encontrar la presentación explicativa sobre como realizar la integración para nuevos proyectos. Si aun así no tienes claro como realizarlo siempre puedes empezar instalando Docker y consiguiendo lanzar tu aplicación dentro de él. Una vez hecho esto el resto del camino es sencillo. Animo ! ! !

# Idea general

La idea es tener un sistema de despliegue e integración continua durante el desarrollo de los proyectos con el fin de facilitar tanto el desarrollo como la integración de los subsistemas. Para ello se ha pensado que dicha integración constará de 3 partes:

1. Fase make. En esta fase se descarga el código tras una modificación y se prepara para ser lanzado. En ocasiones podrían ejecutarse test para comprobar su integridad antes del despliegue.
2. Fase beta. Esta fase se ejecuta automáticamente tras la finalización de la fase make. En esta fase se elimina la aplicación ya desplegada y se despliega la compilada en la fase make.
3. Fase stable. Esta fase se ejecuta manualmente. Se diferencia de la fase beta en la estabilidad, algo necesario para la interacción por parte de los otros subsistemas con él. El código ejecutado en esta fase debe ser el mismo que el de la fase beta para corroborar su estabilidad antes de ejecutar este despliegue.



# Añadir un proyecto
Cada proyecto tiene sus propios requisitos por lo que se intenta ser lo más flexible posible.
## Fase make
En esta fase se busca descargar el proyecto, ejecutar los test (si es posible) y ejecutar todas las acciones oportunas justo antes de desplegar el proyecto.

Primeramente debemos decir donde se realizará dicha fase. Para ello Administrar Jenkins > Configurar el sistema > Nube > Docker y añadimos un docker template. Debe ser una imagen de jenkins slave con los programas necesarios para ejecutar esta fase (siempre debe estar git y ssh) la cual se especificará en el campo Docker Image. Si por ejemplo se va a ejecutar un proyecto maven es recomendable usar siempre la misma carpeta del repositorio maven para evitar descargarlo todo constantemente (Volumes > `/home/egcuser/carpetaCompartidaMavenM2/:/home/jenkins/.m2/`). Tras cada ejecución se debe eliminar el volumen de datos que se genera automáticamente (marcar casilla Remove volumes). Puesto que la conexión al esclavo se realiza por ssh es necesario añadir credenciales con el nombre de usaurio y contraseña de conexión. Es necesario configurar una etiqueta en el campo Labels a la que se hará referencia en la configuración del proyecto.
En caso de requerir maven habrá que configurar en jenkins donde se encuentra la ruta remota del mismo. Administrar Jenkins > Global Tool Configuration > Maven > Instalaciones de maven. Poner el nombre (lo ideal es el mismo que se puso al label del jenkins slave) y decir la ruta donde se encuentras del docker.

Una vez configurado el esclavo se añadirá la fase make. Para ello seleccionaremos Nueva Tarea, nombre AgoraUS-Gx-ProjectName_make y seleccionaremos un proyecto maven o de estilo libre. Lo configuraremos de la siguiente forma:
- Desechar ejecuciones antiguas. Necesario para no ocupar demasiado espacio en la máquina.
- Restringir donde se puede ejecutar este proyecto. En el campo expresión pondremos en label que le pusimos al esclavo anteriormente.
- Configurar el origen del código fuente > Git. Rellenamos correctamente la URL y la rama deseada.
- Disparadores de ejecución > Build when a change is pushed to GitHub.
- Entorno de ejecución > Add timestamps to the Console Output
- Pasos previos > Ejecutar línea de comandos (shell).Si es necesario ejecutar algún comando concreto (desplegar un contenedor de mysql por ejemplo) antes de la ejecución de la fase make se deberá depositar el script en la carpeta de este repositorio `AgoraUS/Gx-ProjectName/pre_make.sh`. Para seleccionarlo se debe poner la ruta (`bash $JENKINS_HOME/continuous-delivery-integration/AgoraUS/Gx-ProjectName/beta.sh`) en la configuración del proyecto > General > Prepare an environment for the run > Script File Path.
- Proyecto. Seleccionamos el maven correspondiente a nuestro esclavo, indicamos donde se encuentra el pom y los pasos a ejecutar por maven (clean compile war:war)
- Pasos posteriores > Ejecutar sólo cuando la ejecución fué buena o inestable.
- Acciones para ejecutar después > Guardar los archivos generados. Es necesario conservar el sql (*.sql)
- Acciones para ejecutar después > Ejecutar otros proyectos. Poner AgoraUS-Gx-ProjectName_beta y Lanzar incluso si el resultado de la ejecución fué inestable.

## Fase beta y Fase stable
Para ello seleccionaremos Nueva Tarea, nombre AgoraUS-Gx-ProjectName_beta/stable y seleccionaremos un proyecto de estilo libre. Lo configuraremos de la siguiente forma:
- Ejecutar > Ejecutar línea de comandos (shell). Ponemos el comando `bash $JENKINS_HOME/continuous-delivery-playground/AgoraUS/Gx-ProjectName/{beta/stable}.sh`. Esto implica que el script se deberá depositar en la carpeta de este repositorio `AgoraUS/Gx-ProjectName/{beta/stable}.sh`

## Configurar "Build when a change is pushed to GitHub"
Para ello nos iremos al repositorio github del proyecto a desplegar, configuración > Integración y servicios y añadimos un servicio Jenkins (GitHub plugin). La URL es: `https://jenkins.egc.duckdns.org/github-webhook/`

# Instalación del sistema

Este sistema solo deberá estar instalado donde se vaya a desplegar todo. Es necesario tener instalado Docker y desplegar los siguientes contenedores:
- [Proxy inverso](https://hub.docker.com/r/jwilder/nginx-proxy/). Ejecutar el script [1startReverseProxy.sh](installationScripts/1startReverseProxy.sh)
- [Let's Encrypt](https://hub.docker.com/r/jrcs/letsencrypt-nginx-proxy-companion/). Ejecutar el script [2starLetsEncrypt.sh](installationScripts/2starLetsEncrypt.sh)
- [Jenkins](https://hub.docker.com/r/library/jenkins/). Ejecutar el script [3startJenkins.sh](installationScripts/3startJenkins.sh)


## Configuración jenkins

Es necesario instalar el plugin [Deploy plugin](https://wiki.jenkins-ci.org/display/JENKINS/Docker+Plugin) ([GitHub](https://github.com/jenkinsci/docker-plugin)). Para configurarlo iremos a Administrar Jenkins > Configurar el sistema > Añadir una nueva nube (abajo) > Docker y usaremos las siguientes opciones:
- Docker Name: docker_on_localhost
- Docker URL: tcp://192.168.20.84:4243
- Probamos la configuración en el botón "test configuration" y anotamos correctamente el "Docker API Version"
- Connection Timeout: 5
- Read Timeout: 5

Para configurar dicho plugin habría que conectarse a "unix:///var/run/docker.sock" pero, puesto que existe algún fallo en java, este método no es posible. Por ello se ha tenido que habilitar un puerto al que conectarse. En el host crear el archivo y carpeta `/etc/systemd/system/docker.service.d/docker.conf` y añadir:
```bash
[Service]
ExecStart=
ExecStart=/usr/bin/dockerd --tls=false -H tcp://192.168.20.84:4243 -H unix:///var/run/docker.sock
```
Posteriormente ejecutar `sudo systemctl daemon-reload` y `sudo systemctl restart docker` con el fin de que cargue la configuración.
Está configuración no es totalmente segura puesto que no requiere autenticación pero al limitarlo solo al equipo local el riesgo se minimiza aunque no se disipa.

(Fuente: https://docs.docker.com/engine/admin/#centos--red-hat-enterprise-linux--fedora)


# Organización del proyecto
- [installationScripts](installationScripts). En esta carpeta se encuentran todos los scripts de instalación de este sistema.
- [Dockers](Dockers). En esta carpeta se encuentran todos los contenedores necesarios para el desarrollo del despliegue continuo siempre y cuando los necesarios no estén subidos en sus repositorios originales.
- [AgoraUS](AgoraUS). En esta carpeta se almacenan todas las configuraciones necesarias para ejecutar las 3 fases del despliegue de cada proyecto.

# Problemas posibles/encontrados
## No se generan los certificados automáticamente o los contenedores no pueden hacer peticiones a cualquier subdominio en la misma máquina
El contenedor da problemas puesto que la máquina no es capaz de resolver su propio nombre. Es necesario ya que antes de renovar el certificado comprueba que el dominio esté en pie. La solución fue decirle que sus direcciones las resuelva como localhost.

(fuente: https://support.rackspace.com/how-to/centos-hostname-change/)

# Inspiración y fuentes
- https://blog.philipphauer.de/tutorial-continuous-delivery-with-docker-jenkins/
- https://www.wouterdanes.net/2014/04/11/continuous-integration-using-docker-maven-and-jenkins.html
- http://christoph-burmeister.eu?p=2989
- http://webapp.org.ua/sysadmin/setting-up-nginx-ssl-reverse-proxy-for-tomcat/
 
