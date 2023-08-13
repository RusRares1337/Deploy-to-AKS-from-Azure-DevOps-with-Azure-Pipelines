FROM mcr.microsoft.com/dotnet/sdk:7.0 AS build
WORKDIR /App

# Copy csproj and restore as distinct layers
COPY *.csproj .
RUN dotnet restore

# Copy everything else and build website
COPY WebApp.csproj .
RUN dotnet publish -c release -o /App --no-restore

# Final stage / image
FROM mcr.microsoft.com/dotnet/aspnet:7.0
WORKDIR /WebApp
COPY --from=build /App ./
ENTRYPOINT ["dotnet", "WebApp.dll"]