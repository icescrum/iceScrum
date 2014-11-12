import org.icescrum.atmosphere.IceScrumMeteorHandler

defaultMapping = "/stream/app/*"

servlets = [
        MeteorServletDefault: [
                className: "org.icescrum.IceScrumMeteorServlet",
                mapping: "/stream/app/*",
                handler: IceScrumMeteorHandler,
                initParams: [
                        // Uncomment the line below use native WebSocket support with native Comet support.
                        //"org.atmosphere.useWebSocketAndServlet3": "false",
                        "org.atmosphere.cpr.broadcasterLifeCyclePolicy": "EMPTY_DESTROY",
                        "org.atmosphere.cpr.broadcasterCacheClass": "org.atmosphere.cache.UUIDBroadcasterCache",
                        "org.atmosphere.cpr.AtmosphereInterceptor": """
                org.atmosphere.client.TrackMessageSizeInterceptor,
                org.atmosphere.interceptor.AtmosphereResourceLifecycleInterceptor,
                org.atmosphere.interceptor.HeartbeatInterceptor,
                org.atmosphere.interceptor.OnDisconnectInterceptor
            """
                ]
        ]
]