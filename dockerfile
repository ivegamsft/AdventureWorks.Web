# Stage 1: Build
FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /app

# Copy csproj and restore as distinct layers
COPY *.sln .
COPY AdventureWorks.Web.csproj .
RUN dotnet restore ./AdventureWorks.Web.csproj

# Copy everything else and build
COPY . .
RUN dotnet publish ./AdventureWorks.Web.csproj -c Release -o /app

# Stage 2: Runtime
FROM mcr.microsoft.com/dotnet/aspnet:9.0-alpine AS runtime
WORKDIR /app

# Install required packages
RUN apk add --no-cache icu-libs tiff libgdiplus libc-dev tzdata

# Set the globalization invariant mode to false
ENV DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=false

# Copy the build output from the build stage
COPY --from=build /app .

# Set the ASPNETCORE_URLS environment variable
ENV ASPNETCORE_URLS=http://+:8080

# Expose port 8080
EXPOSE 8080

# Run the application
ENTRYPOINT ["dotnet", "AdventureWorks.Web.dll"]