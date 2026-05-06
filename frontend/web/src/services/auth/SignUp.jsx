import {createClient} from "@supabase/supabase-js";

const supabase = createClient(
    import.meta.env.VITE_SUPABASE_URL,
    import.meta.env.VITE_SUPABASE_PUBLISHABLE_KEY
);

const backendUrl = import.meta.env.VITE_BACKEND_URL;

export async function SignUp({firstName, lastName, email, password, phone, role, county}) {
    if (!backendUrl) {
        return {success: false, error: "Backend URL is not configured."};
    }

    const phoneNumber = Number(phone);
    if (!Number.isInteger(phoneNumber)) {
        return {success: false, error: "Phone number must contain digits only."};
    }

    const {data, error} = await supabase.auth.signUp({email, password});
    if (error) {
        return {success: false, error: error.message};
    }

    const user = data?.user;
    if (!user?.id) {
        return {success: false, error: "Registration completed, but no user record was returned."};
    }

    try {
        const syncReg = await fetch(`${backendUrl}/users/sync`, {
            method: "POST",
            headers: {"Content-Type": "application/json"},
            body: JSON.stringify({
                user_id: user.id,
                first_name: firstName,
                last_name: lastName,
                email_address: email,
                phone_number: phoneNumber,
                role,
                county_work: role === "manager" ? county : null,
            }),
        });

        if (!syncReg.ok) {
            let errorMessage = "Registration failed while syncing your profile.";

            try {
                const errorData = await syncReg.json();
                if (typeof errorData?.detail === "string") {
                    errorMessage = errorData.detail;
                }
            } catch {
                // Keep the generic message when the backend does not return JSON.
            }

            return {success: false, error: errorMessage};
        }
    } catch {
        return {success: false, error: "Registration failed while contacting the backend."};
    }

    return {success: true, user};
}
