import org.icescrum.atmosphere.IceScrumMeteorHandler

defaultMapping = "/stream/app/*"

servlets = [
        MeteorServletDefault: [
                className : "org.icescrum.atmosphere.IceScrumMeteorServlet",
                mapping   : "/stream/app/*",
                handler   : IceScrumMeteorHandler,
                initParams: [
                        "org.atmosphere.cpr.AtmosphereFramework.analytics"                           : false,
                        "org.atmosphere.interceptor.HeartbeatInterceptor.heartbeatFrequencyInSeconds": 15, // seconds
                        "org.atmosphere.cpr.CometSupport.maxInactiveActivity"                        : 30 * 60000, // 30 minutes
                        "org.atmosphere.cpr.broadcasterClass"                                        : "org.icescrum.atmosphere.IceScrumBroadcaster",
                        "org.atmosphere.cpr.AtmosphereInterceptor"                                   : """
                                org.atmosphere.interceptor.IdleResourceInterceptor,
                                org.atmosphere.interceptor.PaddingAtmosphereInterceptor,
                                org.atmosphere.client.TrackMessageSizeInterceptor,
                                org.atmosphere.interceptor.AtmosphereResourceLifecycleInterceptor,
                                org.atmosphere.interceptor.HeartbeatInterceptor,
                                org.atmosphere.interceptor.OnDisconnectInterceptor
                        """,
                ]
        ]
]