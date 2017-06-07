{
    "listening_port" : 55555,
    "storage_path" : "/mnt/sync/config",
    "vendor" : "docker",
    "display_new_version": false,
    "use_upnp": false,

    "directory_root_policy" : "belowroot",
    "directory_root" : "/mnt/",

    "webui" :
    {
        "allow_empty_password" : false,
        "dir_whitelist" : [ "/mnt/sync/folders", "/mnt/mounted_folders" ]
    },

    "shared_folders" : [
      {
        "secret": "${shared_secret}",
        "dir": "/mnt/sync/folders/swarm",
        "use_relay_server": false,
        "use_tracker": true,
        "search_lan": true,
        "use_sync_trash": true
      }
    ]
}
