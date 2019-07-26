# -----------
# Image de co
# -----------
FROM maven:3-jdk-8-slim as builder

WORKDIR /build

ENV MAVEN_OPTS="-Dmaven.repo.local=/build/.m2/repository"

COPY pom.xml ./

# Les 3 lignes suivantes permettent de réutiliser le cache maven tant que le fichier pom.xml n'est pas modifié
RUN mvn --batch-mode --fail-never clean verify
ADD . .
RUN mvn --batch-mode -Dmaven.test.skip=true package

# -----------
# Image du runtime
# -----------
FROM openjdk:8-jre-slim as runtime

WORKDIR /app
EXPOSE 8080

# Recopie du jar construit dans l'image du builder
COPY --from=builder /build/target/spring-boot-docker*.jar ./spring-boot-docker.jar

# Lancement de l'application
ENTRYPOINT ["java", "-jar", "/app/spring-boot-docker.jar"]

