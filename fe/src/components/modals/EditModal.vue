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
      :model="registerForm"
      :rules="rules"
      label-width="120px"
      @validate="validateHandler"
    >
      <ElFormItem label="First name" prop="firstName">
        <ElInput v-model="registerForm.firstName" />
      </ElFormItem>
      <ElFormItem label="Last name" prop="lastName">
        <ElInput v-model="registerForm.lastName" />
      </ElFormItem>
      <ElFormItem label="Email address" prop="emailAddress">
        <ElInput v-model="registerForm.emailAddress" />
      </ElFormItem>
    </ElForm>
    <template #footer>
      <ElButton
        type="primary"
        :disabled="!isFormValid"
        @click="doRegister"
      >
        Confirm
      </ElButton>
    </template>
  </ElDialog>
</template>

<script>
  import { mapActions, mapWritableState } from 'pinia';
  import { useAlertsStore } from '@/stores/alerts.js';
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
        /**
         * Form data model
         */
        registerForm: {
          firstName: '',
          lastName: '',
          emailAddress: '',
        },
        /**
         * Form field validation rules
         */
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
      /**
       * Check if the form is valid
       *
       * @returns {boolean}
       */
      isFormValid() {
        return Object.values(this.formValidity).every((isValid) => isValid);
      },
    },
    methods: {
      ...mapActions(useAuthStore, ['setUser']),
      ...mapActions(useAlertsStore, ['addAlert']),

      /**
       * Call API to register a new user, sign them in, and redirect to Home
       */
      async doRegister() {
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
          this.addAlert({
            title: 'Error registering user. Have you already signed up?',
            type: 'error',
          });
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
