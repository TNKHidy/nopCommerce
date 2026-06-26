# =========================
# build
# =========================
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build

WORKDIR /src
COPY ./src ./

RUN dotnet restore NopCommerce.sln

RUN dotnet build NopCommerce.sln -c Debug --no-restore

RUN dotnet publish Nop.Web/Nop.Web.csproj -c Debug -o /app/published \
    --no-build \
    -p:DebugType=portable \
    -p:DebugSymbols=true \
    -p:Optimize=false

# =========================
# runtime
# =========================
FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS runtime

WORKDIR /app

COPY --from=build /app/published .

ENV ASPNETCORE_URLS=http://+:80
ENV ASPNETCORE_ENVIRONMENT=Development
ENV DOTNET_ENVIRONMENT=Development

EXPOSE 80

ENTRYPOINT ["dotnet", "Nop.Web.dll"]