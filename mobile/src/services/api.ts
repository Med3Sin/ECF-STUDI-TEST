import axios from 'axios';

const API_URL = 'http://your-api-url:8080/api';

const api = axios.create({
  baseURL: API_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

export const uploadMedia = async (file: any, type: string) => {
  const formData = new FormData();
  formData.append('file', file);
  formData.append('type', type);

  try {
    const response = await api.post('/media/upload', formData, {
      headers: {
        'Content-Type': 'multipart/form-data',
      },
    });
    return response.data;
  } catch (error) {
    console.error('Upload failed:', error);
    throw error;
  }
};

export const getMediaList = async () => {
  try {
    const response = await api.get('/media');
    return response.data;
  } catch (error) {
    console.error('Failed to fetch media list:', error);
    throw error;
  }
};

export const deleteMedia = async (id: string) => {
  try {
    await api.delete(`/media/${id}`);
  } catch (error) {
    console.error('Failed to delete media:', error);
    throw error;
  }
};

export default api; 