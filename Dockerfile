FROM tomcat:9-jdk11-corretto

USER root

WORKDIR /usr/local/tomcat

RUN if [ "$(ls -a webapps | wc -l)" -eq 2 ] ; then mv webapps webapp1 ; fi

RUN mv webapps.dist webapps

COPY *.war /usr/local/tomcat/webapps/

EXPOSE 8080

CMD catalina.sh start; sleep inf


#CMD ["catalina.sh", "run"]
