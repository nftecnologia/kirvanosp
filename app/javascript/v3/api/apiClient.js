import axios from 'axios';

const { apiHost = '' } = window.kirvanoConfig || {};
const wootAPI = axios.create({ baseURL: `${apiHost}/` });

export default wootAPI;
