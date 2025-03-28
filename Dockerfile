FROM eclipse-temurin:17-jdk-jammy as base

ARG REPOSITORY_URL
ARG REPOSITORY_AUTH_USER
ARG REPOSITORY_AUTH_TOKEN

RUN mkdir -p /root/.m2 \
    && mkdir /root/.m2/repository
# Copy maven settings, containing repository configurations
COPY .mvn/settings.xml /root/.m2

WORKDIR /app
COPY .mvn/ .mvn
COPY mvnw pom.xml ./
RUN ./mvnw dependency:resolve
COPY src ./src

FROM base as test
ARG REPOSITORY_URL
ARG REPOSITORY_AUTH_USER
ARG REPOSITORY_AUTH_TOKEN

RUN ["./mvnw", "test"]

FROM scratch as export-test-results
COPY --from=test /app/target/surefire-reports/*Test.txt /

FROM base as development
ARG REPOSITORY_URL
ARG REPOSITORY_AUTH_USER
ARG REPOSITORY_AUTH_TOKEN
CMD ["./mvnw exec:java -Dexec.mainClass='com.gda.example.app.HelloMain'" ]

FROM base as build
ARG REPOSITORY_URL
ARG REPOSITORY_AUTH_USER
ARG REPOSITORY_AUTH_TOKEN
RUN ./mvnw package

FROM scratch as export-jar
COPY --from=build /app/target/myserver-*.jar .

FROM eclipse-temurin:17-jre-jammy as production
EXPOSE 8080

RUN mkdir /opt/app
RUN groupadd -g 10001 javauser && \
   useradd javauser -u 10000 -g javauser \
   && chown -R javauser:javauser /opt/app

COPY --from=build /app/target/finaltask-*.jar /opt/app/finaltask.jar
USER javauser:javauser
CMD ["java", "-Dport=9090", "-jar", "/opt/app/finaltask.jar"]

