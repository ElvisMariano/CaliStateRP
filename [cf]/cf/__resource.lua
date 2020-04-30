resource_manifest_version "44febabe-d386-4d18-afbe-5e627f4af937"

shared_scripts {
    "locale.lua",
    "config.lua",
}

server_scripts {
    "@mysql-async/lib/MySQL.lua",
    "server/server.lua",
}

client_scripts {
    "client/client.lua",
    "client/menu.lua",
    "client/wrapper.lua",
}

export "GetFramework"
server_export "GetFramework"