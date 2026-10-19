# DEMO FIXTURE. The base images below are deliberately upstream Microsoft
# Container Registry images. This file is the "before" state that Guardener
# migrates. Don't copy it as a reference architecture. See ../../README.md.
#
# Tier: complex. Base images come from a registry other than Docker Hub.
# Expected: Guardener resolves mcr.microsoft.com references the same way it
# resolves Docker Hub ones. The runtime stage has no RUN, so it is eligible for
# a one-click change.

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build

WORKDIR /src

COPY Billing.csproj ./
RUN dotnet restore Billing.csproj

COPY . ./
RUN dotnet publish Billing.csproj -c Release -o /app/publish --no-restore

FROM mcr.microsoft.com/dotnet/aspnet:8.0

WORKDIR /app

ENV ASPNETCORE_URLS=http://0.0.0.0:8080

COPY --from=build /app/publish ./

EXPOSE 8080

ENTRYPOINT ["dotnet", "Billing.dll"]
