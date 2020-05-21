---

# Create users for the system
# These will be specific for all systems

- name: Create Users
  user:
    name: "{{ item.name }}"
    comment: "{{ item.comment }}"
    createhome: "{{ item.createhome }}"
    home: "{{ item.home }}"
    password: "{{ default_password }}"
    generate_ssh_key: "{{ item.generate_ssh_key }}"
    ssh_key_bits: "{{ item.ssh_key_bits }}"
    ssh_key_file: "{{ item.ssh_key_file }}"
    update_password: "{{ item.update_password }}"
    groups: "{{ item.groups }}"
  with_items:
    - "{{ default_users }}"
    - "{{ extra_users }}"
  loop_control:
    label: "{{ item.name  }}"
                  
