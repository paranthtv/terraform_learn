
resource "google_storage_bucket" "bucket_creation" {
 for_each = { for bucket in var.buckets : bucket.name => bucket }
 name                        = "XXX-${each.value.name}-${var.env}"
 location                    = each.value.location
 project                     = "${var.project}"
 storage_class               = each.value.storage_class
 force_destroy               = each.value.force_destroy
 uniform_bucket_level_access = each.value.uniform_bucket_lvl_access
 versioning {
 enabled                     = each.value.versioning
 }
 
 dynamic "lifecycle_rule" {
    for_each = each.value.lifecycle_delete_enabled ? [1] : []
    content {

    condition {
      age = each.value.lifecycle_delete_days
    }
    action {
      type = "Delete"
    }
	}
  }
 
 dynamic "lifecycle_rule" {
    for_each = each.value.lifecycle_set_nearline ? [1] : []
    content {

    condition {
      age            = each.value.lifecycle_set_nearline_days
      with_state     = "ANY"
    }

    action {
      type          = "SetStorageClass"
      storage_class = "NEARLINE"
    }
	}
  } 
 
 dynamic "lifecycle_rule" {
    for_each = each.value.lifecycle_set_coldline ? [1] : []
    content {

    condition {
      age            = each.value.lifecycle_set_coldline_days
      with_state     = "ANY"
    }

    action {
      type          = "SetStorageClass"
      storage_class = "COLDLINE"
    }
	}
  } 
  
 
 dynamic "lifecycle_rule" {
    for_each = each.value.lifecycle_set_archive ? [1] : []
    content {

    condition {
      age            = each.value.lifecycle_set_archive_days
      with_state     = "ANY"
    }

    action {
      type          = "SetStorageClass"
      storage_class = "ARCHIVE"
    }
	}
  } 
  
}

locals {
  flattened_members = flatten([
    for bucket in var.buckets : [
      for member in (bucket.members != null ? bucket.members : []) : {
		bucket = bucket.name
        member = member.member
        role   = member.role
      }
    ]
  ])
}
 
resource "google_storage_bucket_iam_member" "member_role_access" {
  for_each = {
    for idx,member in local.flattened_members : "${member.bucket}-${idx}" => member
  }
 
  bucket = google_storage_bucket.bucket_creation[each.value.bucket].name
  role   = each.value.role
  member = "user:${each.value.member}@xxx.com"
  
  #set dependency
  depends_on =[google_storage_bucket.bucket_creation]
}

#-----------------------------------service account access--------------------------------------#
locals {
  flattened_service_accounts = flatten([
    for bucket in var.buckets : [
      for service_account in (bucket.service_accounts != null ? bucket.service_accounts : []) : {
		bucket = bucket.name
        service_account = service_account.service_account
        role   = service_account.role
      }
    ]
  ])
}
 
resource "google_storage_bucket_iam_member" "service_account_role_access" {
  for_each = {
    for idx,service_account in local.flattened_service_accounts : "${service_account.bucket}-${idx}" => service_account
  }
 
  bucket = google_storage_bucket.bucket_creation[each.value.bucket].name
  role   = each.value.role
  member = "serviceAccount:${each.value.service_account}@${var.project}.iam.gserviceaccount.com"
  
  #set dependency
  depends_on =[google_storage_bucket.bucket_creation]
}


#-----------------------------------group access--------------------------------------#
# Flatten the groups list
locals {
  flattened_groups = flatten([
    for bucket in var.buckets : [
      for group in (bucket.groups != null ? bucket.groups : []) : {
		bucket = bucket.name
        group = group.group
        role   = group.role
      }
    ]
  ])
}
 
resource "google_storage_bucket_iam_member" "group_role_access" {
  for_each = {
    for idx,group in local.flattened_groups : "${group.bucket}-${idx}" => group
  }
 
  bucket = google_storage_bucket.bucket_creation[each.value.bucket].name
  role   = each.value.role
  member = "group:${each.value.group}@XXX.COM"
  
  #set dependency
  depends_on =[google_storage_bucket.bucket_creation]
}


#-----------------------------------environment specific------------------------------------------

resource "google_storage_bucket" "bucket_creation_with_env_specifc" {
 for_each = { for bucket in var.bucket_specific_env : bucket.name => bucket 
 if bucket.bucket_required_env == var.env}
 name                        = "${each.value.name}"
 location                    = each.value.location
 project                     = "${var.project}"
 storage_class               = each.value.storage_class
 force_destroy               = each.value.force_destroy
 uniform_bucket_level_access = each.value.uniform_bucket_lvl_access
 versioning {
 enabled                     = each.value.versioning
 }
 
 dynamic "lifecycle_rule" {
    for_each = each.value.lifecycle_delete_enabled ? [1] : []
    content {

    condition {
      age = each.value.lifecycle_delete_days
    }
    action {
      type = "Delete"
    }
	}
  }
 
 dynamic "lifecycle_rule" {
    for_each = each.value.lifecycle_set_nearline ? [1] : []
    content {

    condition {
      age            = each.value.lifecycle_set_nearline_days
      with_state     = "ANY"
    }

    action {
      type          = "SetStorageClass"
      storage_class = "NEARLINE"
    }
	}
  } 
 
 dynamic "lifecycle_rule" {
    for_each = each.value.lifecycle_set_coldline ? [1] : []
    content {

    condition {
      age            = each.value.lifecycle_set_coldline_days
      with_state     = "ANY"
    }

    action {
      type          = "SetStorageClass"
      storage_class = "COLDLINE"
    }
	}
  } 
  
 
 dynamic "lifecycle_rule" {
    for_each = each.value.lifecycle_set_archive ? [1] : []
    content {

    condition {
      age            = each.value.lifecycle_set_archive_days
      with_state     = "ANY"
    }

    action {
      type          = "SetStorageClass"
      storage_class = "ARCHIVE"
    }
	}
  } 
  
}


# Flatten the members list
locals {
  flattened_members_with_env_specific = flatten([
    for bucket in var.bucket_specific_env : [
      for member in (bucket.members != null ? bucket.members : []) : {
		bucket = bucket.name
        member = member.member
        role   = member.role
		bucket_required_env=bucket.bucket_required_env
      }
    ]
  ])
}

resource "google_storage_bucket_iam_member" "members_with_env_specific" {
  for_each = {
    for idx,member in local.flattened_members_with_env_specific : "${member.bucket}-${idx}" => member
	if member.bucket_required_env == var.env
  }
 
  bucket = google_storage_bucket.bucket_creation_with_env_specifc[each.value.bucket].name
  role   = each.value.role
  member = "user:${each.value.member}@xxx.com"
  
  #set dependency
  depends_on =[google_storage_bucket.bucket_creation_with_env_specifc]
}


#-----------------------------------service account access--------------------------------------#
# Flatten the service_account list
locals {
  flattened_service_accounts_with_env_specific = flatten([
    for bucket in var.bucket_specific_env : [
      for service_account in (bucket.service_accounts != null ? bucket.service_accounts : []) : {
		bucket = bucket.name
        service_account = service_account.service_account
        role   = service_account.role
		bucket_required_env=bucket.bucket_required_env
      }
    ]
  ])
}
 
resource "google_storage_bucket_iam_member" "service_account_role_access_with_env_specific" {
  for_each = {
    for idx,service_account in local.flattened_service_accounts_with_env_specific : "${service_account.bucket}-${idx}" => service_account
	if service_account.bucket_required_env == var.env
  }
 
  bucket = google_storage_bucket.bucket_creation_with_env_specifc[each.value.bucket].name
  role   = each.value.role
  member = "serviceAccount:${each.value.service_account}@${var.project}.iam.gserviceaccount.com"
  
  #set dependency
  depends_on =[google_storage_bucket.bucket_creation_with_env_specifc]
}


#-----------------------------------group access--------------------------------------#
# Flatten the groups list
locals {
  flattened_groups_with_env_specific = flatten([
    for bucket in var.bucket_specific_env : [
      for group in (bucket.groups != null ? bucket.groups : []) : {
		bucket = bucket.name
        group = group.group
        role   = group.role
		bucket_required_env=bucket.bucket_required_env
      }
    ]
  ])
}
 
resource "google_storage_bucket_iam_member" "group_role_access_with_env_specific" {
  for_each = {
    for idx,group in local.flattened_groups_with_env_specific : "${group.bucket}-${idx}" => group
	if group.bucket_required_env == var.env
  }
 
  bucket = google_storage_bucket.bucket_creation_with_env_specifc[each.value.bucket].name
  role   = each.value.role
  member = "group:${each.value.group}@xxx.com"
  
  #set dependency
  depends_on =[google_storage_bucket.bucket_creation_with_env_specifc]
}
