import { expect, vi } from 'vitest';
import component from '@/components/modals/RegisterModal.vue';
import { createTestWrapper } from '../utils.js';

vi.mock('vue-router');

describe('EditModal', () => {
  let wrapper;
  const createWrapper = async (initialData = {}) => {
    wrapper = await createTestWrapper({
      isShallow: false,
      component,
      options: {
        slots: { ...initialData.slots },
        propsData: {
          ...initialData.propsData,
        },
        pinia: {
          initialState: {
            auth: {
              ...initialData.user,
            },
          },
        },
      },
    });
  };

  it('should validate the form', async () => {
    await createWrapper({
      user: {
        isEditModalVisible: true,
      },
    });

    expect(wrapper.vm.isFormValid).toBeFalsy();

    await wrapper.setData({
      registerForm: {
        firstName: 'test',
        lastName: 'test',
        emailAddress: 'test',
      },
    });
  });
});
