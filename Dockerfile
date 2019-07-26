# -----------
# Image de construction
# -----------
FROM maven:3-jdk-8-slim as builder

WORKDIR /build

ENV MAVEN_OPTS="-Dmaven.repo.local=/build/.m2/repository"

# Les 4 instructions ci-dessous permettent de profiter du cache docker local tant que le fichier pom.xml n'est pas modifié

# On ne copie que le fichier pom.xml dans un premier temps
COPY pom.xml ./
# Puis on lance une analyse du pom.xml pour que maven télécharge les dépendances
RUN mvn --batch-mode --fail-never clean verify
# On ajoute le reste du code source
ADD . .
# On lance le packaging réel
RUN mvn --batch-mode -Dmaven.test.skip=true package

# -----------
# Image du runtime
# -----------
FROM openjdk:8-jre-slim as runtime

WORKDIR /app
EXPOSE 8080

# Recopie du jar construit dans l'image du builder
COPY --from=builder /build/target/spring-boot-docker*.jar ./spring-boot-docker.jar

# Commande de lancement de l'application
ENTRYPOINT ["java", "-jar", "/app/spring-boot-docker.jar"]

