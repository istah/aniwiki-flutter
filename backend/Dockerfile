FROM dart:stable AS build
WORKDIR /app
COPY pubspec.yaml pubspec.lock* ./
RUN dart pub get
COPY . .
RUN dart compile exe bin/server.dart -o /app/server

FROM gcr.io/distroless/cc-debian12
ENV PORT=8787
EXPOSE 8787
COPY --from=build /app/server /server
COPY --from=build /app/.env.example /.env
CMD ["/server"]