variable "project" {}

variable "env" {}

variable "buckets" {
    type = list (object ({
	name = string
	location =string
	storage_class = string
	force_destroy=bool
	uniform_bucket_lvl_access = bool
	public_access_prevention = string  # Subject to object ACLs( bucket_private/project_private, default :project_private )
	lifecycle_delete_enabled = bool
    lifecycle_delete_days = number
	lifecycle_set_nearline = bool
	lifecycle_set_nearline_days = number
	lifecycle_set_coldline = bool
	lifecycle_set_coldline_days = number
	lifecycle_set_archive = bool	
	lifecycle_set_archive_days = number
	versioning = bool
	members                    = optional(list(object({
      member = string
      role   = string })))
	service_accounts           = optional(list(object({
      service_account = string
      role   = string })))  
	groups                      = optional(list(object({
      group = string
      role   = string })))
	}))
	
	default = [
	{
	name="xxx"
	location="EU"
	storage_class="STANDARD"
	force_destroy=false
	uniform_bucket_lvl_access = false
	public_access_prevention = "bucket_private" #bucket_private
	lifecycle_delete_enabled = false
	lifecycle_delete_days = 30
	lifecycle_set_nearline = false
	lifecycle_set_nearline_days = 0
	lifecycle_set_coldline = false	
	lifecycle_set_coldline_days = 0
	lifecycle_set_archive = false
	lifecycle_set_archive_days = 0
	versioning = false
	members                    = [
        {
          member = "xxxx"
          role   = "roles/storage.objectViewer"
        }
      ]
	service_accounts = [
	    { 
		  service_account="xxxx"
		  role   = "roles/storage.objectViewer"
		}
	]  
	groups = [
	    {
		  group="xxxx"
		  role   = "roles/storage.objectViewer"		  
	    }
	]
	}
	]
}	

#-----------------------------------bucket with env specific----------------------------------------------
variable "bucket_specific_env" {
    type = list (object ({
	name = string
	location =string
	storage_class =string
	force_destroy=bool
	uniform_bucket_lvl_access = bool
	public_access_prevention = string  # Subject to object ACLs( bucket_private/project_private)
	lifecycle_delete_enabled = bool
    lifecycle_delete_days = number
	lifecycle_set_nearline = bool
	lifecycle_set_nearline_days = number
	lifecycle_set_coldline = bool
	lifecycle_set_coldline_days = number
	lifecycle_set_archive = bool	
	lifecycle_set_archive_days = number
	versioning = bool
	bucket_required_env= string
	members                    = optional(list(object({
      member = string
      role   = string })))
	service_accounts           = optional(list(object({
      service_account = string
      role   = string })))   
	
	groups                     = optional(list(object({
      group = string
      role   = string })))
	}))
	default = [
	{
	name="xxxxx"
	location="europe-west2"
	storage_class="STANDARD"
	force_destroy=true
	uniform_bucket_lvl_access = false
	public_access_prevention = "bucket_private" #bucket_private/project_private
	lifecycle_delete_enabled = false
	lifecycle_delete_days = 40
	lifecycle_set_nearline = true
	lifecycle_set_nearline_days = 30
	lifecycle_set_coldline = false
	lifecycle_set_coldline_days = 60
	lifecycle_set_archive = false
	lifecycle_set_archive_days = 90
	versioning = false
	bucket_required_env="prod"
	members                    = [
        {
          member = "xxxx"
          role   = "roles/storage.objectViewer"
        },
		{
          member = "xxx"
          role   = "roles/storage.admin"
        }
      ]  
	service_accounts = [
	    { 
		  service_account="xxx"
		  role   = "roles/storage.objectViewer"
		}
	]   
	groups = [
	    {
		  group  = "xxxx"
		  role   = "roles/storage.objectViewer"		  
	    }
	]
	}
	
	]
}	
