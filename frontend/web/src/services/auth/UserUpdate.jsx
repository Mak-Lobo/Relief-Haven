import {createClient} from "@supabase/supabase-js";

const supabase = createClient(
    import.meta.env.VITE_SUPABASE_URL,
    import.meta.env.VITE_SUPABASE_PUBLISHABLE_KEY
);

const backendUrl = import.meta.env.VITE_BACKEND_URL;

export async function updateUserProfile(token, userId, payload) {
    if (!backendUrl) {
        return {success: false, error: "Backend URL is not configured."};
    }

    const authUpdate = await supabase.auth.updateUser({email: payload.email});
    if (authUpdate.error) {
        return {success: false, error: authUpdate.error.message};
    }

    const response = await fetch(`${backendUrl}/users/${userId}`, {
        method: "PUT",
        headers: {
            "Content-Type": "application/json",
            "Authorization": `Bearer ${token}`,
        },
        body: JSON.stringify(payload),
    });

    if (!response.ok) {
        let message = "Unable to update your profile right now.";
        try {
            const data = await response.json();
            if (typeof data?.detail === "string") {
                message = data.detail;
            }
        } catch {
            // keep fallback message
        }
        return {success: false, error: message};
    }

    return {success: true, profile: await response.json()};
}
