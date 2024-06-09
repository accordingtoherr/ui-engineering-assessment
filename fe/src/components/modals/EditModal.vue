<template>
  <ElDialog
    v-model="isEditModalVisible"
    title="Edit User Info"
    width="30%"
    append-to-body
    @close="isEditModalVisible = false"
    @closed="$refs.form.resetFields()"
  >
    <ElForm
      ref="form"
      :model="editForm"
      label-width="120px"
      @validate="validateHandler"
    >
      <ElFormItem label="First name" prop="firstName">
        <ElInput v-model="editForm.firstName" :placeholder="user.firstName" />
      </ElFormItem>
      <ElFormItem label="Last name" prop="lastName">
        <ElInput v-model="editForm.lastName" :placeholder="user.lastName" />
      </ElFormItem>
      <ElFormItem label="Email address" prop="emailAddress">
        <ElInput v-model="editForm.emailAddress" :placeholder="user.emailAddress" />
      </ElFormItem>
    </ElForm>
    <template #footer>
      <ElButton
        type="primary"
        @click="doEdit"
      >
        Confirm Edits
      </ElButton>
    </template>
  </ElDialog>
</template>

<script>
  import { mapActions, mapWritableState, mapState } from 'pinia';
  import { useAlertsStore } from '@/stores/alerts.js';
  import { getUsers } from '@/services/users.js';
  import { useUsersStore } from '@/stores/users.js';
  import { register, setSignedIn } from '@/services/auth.js';
  import { useAuthStore } from '@/stores/auth.js';

  export default {
    name: 'EditModal',
    data() {
      return {
        /**
         * Form field validity
         */
        formValidity: {
          firstName: false,
          lastName: false,
          emailAddress: false,
        },
        localUsers: null,
        /**
         * Form data model
         */
        editForm: {
          firstName: '',
          lastName: '',
          emailAddress: '',
        },
        rules: {
          firstName: [{
            required: true,
            message: 'Required',
          }],
          lastName: [{
            required: true,
            message: 'Required',
          }],
          emailAddress: [{
            required: true,
            message: 'Required',
          }],
        },
      };
    },
    computed: {
      ...mapWritableState(useAuthStore, ['isEditModalVisible']),
      ...mapState(useUsersStore, ['users']),
      ...mapState(useAuthStore, ['user']),
      /**
       * Check if the form is valid
       *
       * @returns {boolean}
       */
      isFormValid() {
        return Object.values(this.formValidity).every((isValid) => isValid);
      },
    },
    watch: {
      users: {
        /**
         * Update localUsers when store data changes
         */
        handler() {
          this.localUsers = this.users.map((user) => user);
        },
        immediate: true,
        deep: true,
      },
      async isModalVisible(isVisible) {
        if (!isVisible) return;

        if (this.editingEvent) {
          this.eventForm = { ...this.editingEvent };
          this.$nextTick(async () => {
            await this.$refs.formRef.validate();
          });
        } else {
          this.resetForm();
          this.$refs.formRef.resetFields();
        }
      },
    },
    methods: {
      ...mapActions(useAuthStore, ['setUser']),
      ...mapActions(useAlertsStore, ['addAlert']),

      /**
       * Load users from the API and save them in the store
       */
      async loadUsers() {
        try {
          const data = await getUsers();

          this.editUsers(data);
        } catch (error) {
          /**
           * Show error alert
           */
          this.addAlert({
            title: 'Error retrieving users.',
            type: 'error',
          });
        }
      },

      /**
       * Call API to edit existing user
       */
      async doEdit() {
        try {
          const data = await register(this.registerForm);

          this.setUser(data);
          setSignedIn(data);
          this.isEditModalVisible = false;
          this.$router.replace({ name: 'Home' });
        } catch {
          /**
           * Show error alert
           */
        }
      },
      /**
       * Set form field validity
       *
       * @param {string} propName
       * @param {boolean} isValid
       */
      validateHandler(propName, isValid) {
        this.formValidity[propName] = isValid;
      },
    },
  };
</script>
