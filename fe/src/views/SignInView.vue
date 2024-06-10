<template>
  <ElCard class="card">
    <template #header>
      Sign In
    </template>
    <ElForm
      ref="form"
      :model="signInForm"
      :rules="rules"
      label-width="120px"
    >
      <ElFormItem label="Email address" prop="emailAddress">
        <ElInput v-model="signInForm.emailAddress" />
      </ElFormItem>
    </ElForm>
    <template #footer>
      <div class="card-footer">
        <ElButton
          @click="isRegisterModalVisible = true"
        >
          Register
        </ElButton>
        <ElButton
          type="primary"
          :disabled="!signInForm.emailAddress"
          @click="doSignIn"
        >
          Sign In
        </ElButton>
      </div>
    </template>
  </ElCard>
</template>

<script>
  import { mapActions, mapWritableState } from 'pinia';
  import { useAlertsStore } from '@/stores/alerts.js';
  import { signIn, setSignedIn } from '@/services/auth.js';
  import { useAuthStore } from '@/stores/auth.js';

  export default {
    name: 'SignInView',
    data() {
      return {
        /**
         * Form model
         */
        signInForm: {},
        /**
         * Form validation rules
         */
        rules: {
          emailAddress: [{
            required: true,
            message: 'Required',
            trigger: 'blur',
          }],
        },
      };
    },
    computed: {
      ...mapWritableState(useAuthStore, ['isRegisterModalVisible']),
      ...mapWritableState(useAuthStore, ['isEditModalVisible']),
    },
    methods: {
      ...mapActions(useAuthStore, ['setUser']),
      ...mapActions(useAlertsStore, ['addAlert']),

      /**
       * Sign in user, set user data in store, and redirect to Home
       */
      async doSignIn() {
        try {
          const data = await signIn(this.signInForm.emailAddress);

          this.setUser(data);
          setSignedIn(data);
          this.$router.replace({ name: 'Home' });
        } catch {
          /**
           * Show error alert
           */
          this.addAlert({
            title: 'User not found. Please verify your email address',
            type: 'error',
          });
        }
      },
    },
  };
</script>

<style scoped>
  .card {
    position: absolute;
    top: 200px;
    left: 50%;
    width: 420px;
    transform: translateX(-50%);
  }

  .card-footer {
    display: flex;
    justify-content: space-between;
  }
</style>
