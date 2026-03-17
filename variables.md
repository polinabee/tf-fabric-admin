workspaces = {
    {
        project_name = "analytics_workspace"
        description = "" #optional
        env = "dev"
        department = "data"
        team = "platform"
        contacts = [] # list pf emails, can be distribution group
        capacity = "" # capacity id, optional
        access = { # lists of emails, service principals, service accounts,and distribution groups with the appropriate role, all nullable
            admins = [] 
            contributors = []
            viewers = []
            members = []
        }
    },
    ...
}

service_principal_info = {
    name = "" #optional
    app_id = xxxx
    secret = xxxx
}