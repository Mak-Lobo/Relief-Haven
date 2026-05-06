// Shelter service with role-based access control
const API_URL = import.meta.env.VITE_BACKEND_URL;

// Helper function to get auth headers
const getAuthHeaders = (token) => ({
    "Content-Type": "application/json",
    "Authorization": `Bearer ${token}`
});

// Check if user has permission for shelter operations
export const checkShelterPermission = (userRole, operation) => {
    const permissions = {
        'command': ['create', 'update', 'deactivate'],
        'manager': ['update_resources']
    };

    return permissions[userRole]?.includes(operation) || false;
};

// Get all shelters (filtered by role/county if manager)
export const getShelters = async (token, userRole, userCounty = null) => {
    try {
        // If manager, get shelters by county
        if (userRole === 'manager' && userCounty) {
            return await getSheltersByCounty(token, userCounty);
        }

        // Otherwise get all shelters
        const response = await fetch(`${API_URL}/shelters`, {
            headers: getAuthHeaders(token)
        });

        if (!response.ok) {
            throw new Error(`Failed to fetch shelters: ${response.statusText}`);
        }

        return await response.json();
    } catch (error) {
        console.error('Error fetching shelters:', error);
        throw error;
    }
};

// Get shelters by county (for managers)
export const getSheltersByCounty = async (token, county) => {
    try {
        const response = await fetch(`${API_URL}/shelters/${county}`, {
            headers: getAuthHeaders(token)
        });

        if (!response.ok) {
            throw new Error(`Failed to fetch shelters by county: ${response.statusText}`);
        }

        return await response.json();
    } catch (error) {
        console.error('Error fetching shelters by county:', error);
        throw error;
    }
};

// Get active shelters only
export const getActiveShelters = async (token) => {
    try {
        const response = await fetch(`${API_URL}/shelters/active`, {
            headers: getAuthHeaders(token)
        });

        if (!response.ok) {
            throw new Error(`Failed to fetch active shelters: ${response.statusText}`);
        }

        return await response.json();
    } catch (error) {
        console.error('Error fetching active shelters:', error);
        throw error;
    }
};

// Get single shelter by ID
export const getShelterById = async (token, shelterId) => {
    try {
        const response = await fetch(`${API_URL}/shelters/${shelterId}`, {
            headers: getAuthHeaders(token)
        });

        if (!response.ok) {
            throw new Error(`Failed to fetch shelter: ${response.statusText}`);
        }

        return await response.json();
    } catch (error) {
        console.error('Error fetching shelter:', error);
        throw error;
    }
};

// Create new shelter (command role only)
export const createShelter = async (token, shelterData, userRole) => {
    if (!checkShelterPermission(userRole, 'create')) {
        throw new Error('Insufficient permissions to create shelter');
    }

    try {
        const response = await fetch(`${API_URL}/shelters/add`, {
            method: 'POST',
            headers: getAuthHeaders(token),
            body: JSON.stringify(shelterData)
        });

        if (!response.ok) {
            throw new Error(`Failed to create shelter: ${response.statusText}`);
        }

        return await response.json();
    } catch (error) {
        console.error('Error creating shelter:', error);
        throw error;
    }
};

// Update shelter details (command role only)
export const updateShelter = async (token, shelterId, shelterData, userRole) => {
    if (!checkShelterPermission(userRole, 'update')) {
        throw new Error('Insufficient permissions to update shelter');
    }

    try {
        const response = await fetch(`${API_URL}/shelters/${shelterId}`, {
            method: 'PUT',
            headers: getAuthHeaders(token),
            body: JSON.stringify(shelterData)
        });

        if (!response.ok) {
            throw new Error(`Failed to update shelter: ${response.statusText}`);
        }

        return await response.json();
    } catch (error) {
        console.error('Error updating shelter:', error);
        throw error;
    }
};

// Update shelter occupancy (command role only)
export const updateShelterOccupancy = async (token, shelterId, occupancyData, userRole) => {
    if (!checkShelterPermission(userRole, 'update')) {
        throw new Error('Insufficient permissions to update shelter occupancy');
    }

    try {
        const response = await fetch(`${API_URL}/shelters/${shelterId}/occupancy`, {
            method: 'PATCH',
            headers: getAuthHeaders(token),
            body: JSON.stringify(occupancyData)
        });

        if (!response.ok) {
            throw new Error(`Failed to update shelter occupancy: ${response.statusText}`);
        }

        return await response.json();
    } catch (error) {
        console.error('Error updating shelter occupancy:', error);
        throw error;
    }
};

// Deactivate shelter (command role only)
export const deactivateShelter = async (token, shelterId, userRole) => {
    if (!checkShelterPermission(userRole, 'deactivate')) {
        throw new Error('Insufficient permissions to deactivate shelter');
    }

    try {
        const response = await fetch(`${API_URL}/shelters/${shelterId}`, {
            method: 'DELETE',
            headers: getAuthHeaders(token)
        });

        if (!response.ok) {
            throw new Error(`Failed to deactivate shelter: ${response.statusText}`);
        }

        return await response.json();
    } catch (error) {
        console.error('Error deactivating shelter:', error);
        throw error;
    }
};

// Get shelter resources
export const getShelterResources = async (token, shelterId) => {
    try {
        const response = await fetch(`${API_URL}/resources/shelter/${shelterId}`, {
            headers: getAuthHeaders(token)
        });

        if (!response.ok) {
            throw new Error(`Failed to fetch shelter resources: ${response.statusText}`);
        }

        return await response.json();
    } catch (error) {
        console.error('Error fetching shelter resources:', error);
        throw error;
    }
};

// Update shelter resources (manager role can do this)
export const updateShelterResource = async (token, resourceId, resourceData, userRole) => {
    if (!checkShelterPermission(userRole, 'update_resources')) {
        throw new Error('Insufficient permissions to update shelter resources');
    }

    try {
        const response = await fetch(`${API_URL}/resources/${resourceId}`, {
            method: 'PUT',
            headers: getAuthHeaders(token),
            body: JSON.stringify(resourceData)
        });

        if (!response.ok) {
            throw new Error(`Failed to update shelter resource: ${response.statusText}`);
        }

        return await response.json();
    } catch (error) {
        console.error('Error updating shelter resource:', error);
        throw error;
    }
};

// Create shelter resource (manager role can do this)
export const createShelterResource = async (token, resourceData, userRole) => {
    if (!checkShelterPermission(userRole, 'update_resources')) {
        throw new Error('Insufficient permissions to create shelter resources');
    }

    try {
        const response = await fetch(`${API_URL}/resources`, {
            method: 'POST',
            headers: getAuthHeaders(token),
            body: JSON.stringify(resourceData)
        });

        if (!response.ok) {
            throw new Error(`Failed to create shelter resource: ${response.statusText}`);
        }

        return await response.json();
    } catch (error) {
        console.error('Error creating shelter resource:', error);
        throw error;
    }
};