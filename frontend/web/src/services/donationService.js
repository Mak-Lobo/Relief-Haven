const API_URL = import.meta.env.VITE_BACKEND_URL;

export const getDonations = async (token) => {
    const response = await fetch(`${API_URL}/donations/`, {
        headers: {
            "Authorization": `Bearer ${token}`
        }
    });

    if (!response.ok) {
        throw new Error("Failed to fetch donations");
    }

    return await response.json();
};
