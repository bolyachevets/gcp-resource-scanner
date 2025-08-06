
#!/bin/bash

# declare -a projects=("a083gt" "bcrbk9" "c4hnrd" "eogruh" "gtksf3" "yfjq17" "yfthig" "k973yf" "p0q6jr" "keee67" "mvnjri" "sbgmug" "okagqp" )
declare -a projects=( "bcrbk9")

# declare -a environments=("dev" "test" "tools" "prod" "integration" "sandbox")
declare -a environments=("dev")


for ev in "${environments[@]}"
do
    for ns in "${projects[@]}"
    do
        echo "project: $ns-$ev"
        PROJECT_ID=$ns-$ev

        if [[ ! -z `gcloud projects describe ${PROJECT_ID} --verbosity=none` ]]; then
            gcloud config set project ${PROJECT_ID}

            echo "Checking databases in project: ${PROJECT_ID}"
            
            # Check Cloud SQL instances
            echo "  Checking Cloud SQL instances..."
            sql_instances=$(gcloud sql instances list --format="value(name,region)" 2>/dev/null)
            if [[ ! -z "$sql_instances" ]]; then
                while IFS=$'\t' read -r instance_name region; do
                    if [[ $region == northamerica-northeast1* ]] || [[ $region == northamerica-northeast2* ]]; then
                        echo "    ✓ Cloud SQL instance '$instance_name' is in Canadian region: $region"
                    else
                        echo "    ⚠️  Cloud SQL instance '$instance_name' is NOT in Canadian region: $region"
                    fi
                done <<< "$sql_instances"
            else
                echo "    No Cloud SQL instances found"
            fi

            # Check Firestore databases
            echo "  Checking Firestore databases..."
            # First check if Firestore API is enabled
            if gcloud services list --enabled --filter="name:firestore.googleapis.com" --format="value(name)" 2>/dev/null | grep -q "firestore.googleapis.com"; then
                firestore_dbs=$(timeout 30 gcloud firestore databases list --format="value(name,locationId)" 2>/dev/null)
                if [[ ! -z "$firestore_dbs" ]]; then
                    while IFS=$'\t' read -r db_name location; do
                        if [[ $location == northamerica-northeast1* ]] || [[ $location == northamerica-northeast2* ]]; then
                            echo "    ✓ Firestore database '$db_name' is in Canadian region: $location"
                        else
                            echo "    ⚠️  Firestore database '$db_name' is NOT in Canadian region: $location"
                        fi
                    done <<< "$firestore_dbs"
                else
                    echo "    No Firestore databases found"
                fi
            else
                echo "    Firestore API not enabled - skipping"
            fi

            # Check Bigtable instances
            echo "  Checking Bigtable instances..."
            # First check if Bigtable API is enabled
            if gcloud services list --enabled --filter="name:bigtableadmin.googleapis.com" --format="value(name)" 2>/dev/null | grep -q "bigtableadmin.googleapis.com"; then
                bigtable_instances=$(timeout 30 gcloud bigtable instances list --format="value(name,displayName)" 2>/dev/null)
                if [[ ! -z "$bigtable_instances" ]]; then
                    while IFS=$'\t' read -r instance_id display_name; do
                        # Get cluster details for each instance
                        clusters=$(timeout 30 gcloud bigtable clusters list --instances=$instance_id --format="value(name,zone)" 2>/dev/null)
                        while IFS=$'\t' read -r cluster_name zone; do
                            if [[ $zone == northamerica-northeast1* ]] || [[ $zone == northamerica-northeast2* ]]; then
                                echo "    ✓ Bigtable instance '$display_name' cluster '$cluster_name' is in Canadian zone: $zone"
                            else
                                echo "    ⚠️  Bigtable instance '$display_name' cluster '$cluster_name' is NOT in Canadian zone: $zone"
                            fi
                        done <<< "$clusters"
                    done <<< "$bigtable_instances"
                else
                    echo "    No Bigtable instances found"
                fi
            else
                echo "    Bigtable API not enabled - skipping"
            fi

            # Check Spanner instances
            echo "  Checking Spanner instances..."
            # First check if Spanner API is enabled
            if gcloud services list --enabled --filter="name:spanner.googleapis.com" --format="value(name)" 2>/dev/null | grep -q "spanner.googleapis.com"; then
                spanner_instances=$(timeout 30 gcloud spanner instances list --format="value(name,config)" 2>/dev/null)
                if [[ ! -z "$spanner_instances" ]]; then
                    while IFS=$'\t' read -r instance_name config; do
                        if [[ $config == *"nam-ane1"* ]] || [[ $config == *"nam-ane2"* ]] || [[ $config == *"northamerica-northeast"* ]]; then
                            echo "    ✓ Spanner instance '$instance_name' is in Canadian configuration: $config"
                        else
                            echo "    ⚠️  Spanner instance '$instance_name' is NOT in Canadian configuration: $config"
                        fi
                    done <<< "$spanner_instances"
                else
                    echo "    No Spanner instances found"
                fi
            else
                echo "    Spanner API not enabled - skipping"
            fi

            # Check Redis instances (Memorystore)
            echo "  Checking Redis instances..."
            # First check if Redis API is enabled
            if gcloud services list --enabled --filter="name:redis.googleapis.com" --format="value(name)" 2>/dev/null | grep -q "redis.googleapis.com"; then
                redis_instances=$(timeout 30 gcloud redis instances list --format="value(name,locationId)" 2>/dev/null)
                if [[ ! -z "$redis_instances" ]]; then
                    while IFS=$'\t' read -r instance_name location; do
                        if [[ $location == northamerica-northeast1* ]] || [[ $location == northamerica-northeast2* ]]; then
                            echo "    ✓ Redis instance '$instance_name' is in Canadian region: $location"
                        else
                            echo "    ⚠️  Redis instance '$instance_name' is NOT in Canadian region: $location"
                        fi
                    done <<< "$redis_instances"
                else
                    echo "    No Redis instances found"
                fi
            else
                echo "    Redis API not enabled - skipping"
            fi

            echo ""

        fi
    done
done