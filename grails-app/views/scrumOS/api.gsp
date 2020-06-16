<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
    <head>
        <meta charset="UTF-8">
        <title>iceScrum Service Swagger</title>
        <asset:stylesheet src="swagger-ui/swagger-ui.css"/>
    </head>
    <body>
        <div id="swagger-ui"></div>
        <asset:javascript src="swagger-ui/swagger-ui-standalone-preset.js"/>
        <asset:javascript src="swagger-ui/swagger-ui-bundle.js"/>
        <script>
            window.onload = function() {
                window.ui = SwaggerUIBundle({
                    url: "${createLink(mapping: 'openAPI', absolute: true)}",
                    dom_id: '#swagger-ui',
                    deepLinking: true,
                    presets: [
                        SwaggerUIBundle.presets.apis,
                        SwaggerUIStandalonePreset
                    ],
                    plugins: [
                        SwaggerUIBundle.plugins.DownloadUrl
                    ],
                    layout: "StandaloneLayout"
                });
            }
        </script>
    </body>
</html>