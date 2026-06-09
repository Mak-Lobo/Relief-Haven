const API_URL = import.meta.env.VITE_BACKEND_URL;

const getAuthHeaders = (token) => ({
    "Content-Type": "application/json",
    "Authorization": `Bearer ${token}`,
});

const normalizeCounty = (county) =>
    county ? county.charAt(0).toUpperCase() + county.slice(1).toLowerCase() : null;

export const getResourceHistory = async (token, userRole, userCounty = null) => {
    try {
        const county = userRole === "manager" ? normalizeCounty(userCounty) : null;

        const sheltersResponse = await fetch(
            county ? `${API_URL}/shelters/${county}` : `${API_URL}/shelters`,
            {headers: getAuthHeaders(token)}
        );

        if (!sheltersResponse.ok) {
            throw new Error(`Failed to fetch shelters: ${sheltersResponse.statusText}`);
        }

        const shelters = await sheltersResponse.json();
        const shelterIds = shelters.map((shelter) => shelter.shelter_id);

        const resourceBatches = await Promise.all(
            shelterIds.map(async (shelterId) => {
                const response = await fetch(`${API_URL}/resources/shelter/${shelterId}`, {
                    headers: getAuthHeaders(token),
                });

                if (!response.ok) {
                    throw new Error(`Failed to fetch shelter resources: ${response.statusText}`);
                }

                const resources = await response.json();
                const shelter = shelters.find((item) => item.shelter_id === shelterId);

                return resources.map((resource) => ({
                    ...resource,
                    shelter_name: shelter?.name ?? "Unknown shelter",
                    county: shelter?.county ?? "Unknown county",
                    subcounty: shelter?.subcounty ?? "Unknown subcounty",
                }));
            })
        );

        return resourceBatches.flat().sort(
            (left, right) => new Date(right.updated_at) - new Date(left.updated_at)
        );
    } catch (error) {
        console.error("Error fetching resource history:", error);
        throw error;
    }
};
