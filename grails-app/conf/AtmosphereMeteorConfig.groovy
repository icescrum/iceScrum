import org.icescrum.atmosphere.IceScrumMeteorHandler

defaultMapping = "/stream/app/*"

servlets = [
        MeteorServletDefault: [
                className: "org.icescrum.atmosphere.IceScrumMeteorServlet",
                mapping: "/stream/app/*",
                handler: IceScrumMeteorHandler,
                initParams: [
                        "org.atmosphere.cpr.AtmosphereFramework.analytics":false,
                        "org.atmosphere.cpr.broadcasterClass": "org.icescrum.atmosphere.IceScrumBroadcaster",
                        "org.atmosphere.cpr.broadcasterCacheClass": "org.atmosphere.cache.UUIDBroadcasterCache",
                        "org.atmosphere.cpr.AtmosphereInterceptor": """
                                org.atmosphere.client.TrackMessageSizeInterceptor,
                                org.atmosphere.interceptor.AtmosphereResourceLifecycleInterceptor,
                                org.atmosphere.interceptor.HeartbeatInterceptor,
                                org.atmosphere.interceptor.OnDisconnectInterceptor
                        """,
                        "org.atmosphere.cpr.broadcasterLifeCyclePolicy": "EMPTY_DESTROY",
                        "org.atmosphere.interceptor.HeartbeatInterceptor.heartbeatFrequencyInSeconds": 30
                ]
        ]
]