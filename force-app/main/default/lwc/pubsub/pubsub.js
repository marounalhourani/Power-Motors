// pubsub.js (Singleton Module)
const events = {};
export const register = (eventName, callback) => {
    if (!events[eventName]) events[eventName] = [];
    events[eventName].push(callback);
};
export const unregister = (eventName, callback) => {
    events[eventName] = events[eventName]?.filter(cb => cb !== callback);
};
export const fireEvent = (eventName, payload) => {
    events[eventName]?.forEach(cb => cb(payload));
};