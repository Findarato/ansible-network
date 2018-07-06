chown -R librenms:librenms /opt/librenms/bootstrap/cache /opt/librenms/storage /opt/librenms/storage/framework/sessions /opt/librenms/storage/framework/views /opt/librenms/storage/framework/cache

setfacl -R -m g::rwx /opt/librenms/bootstrap/cache /opt/librenms/storage /opt/librenms/storage/framework/sessions /opt/librenms/storage/framework/views /opt/librenms/storage/framework/cache

setfacl -d -m g::rwx /opt/librenms/bootstrap/cache /opt/librenms/storage /opt/librenms/storage/framework/sessions /opt/librenms/storage/framework/views /opt/librenms/storage/framework/cache