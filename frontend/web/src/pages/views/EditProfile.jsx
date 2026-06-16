import {useEffect, useState} from "react";
import {useNavigate} from "react-router-dom";
import styles from "../../styles/auth.module.css";
import {useAuth} from "../../context/AuthContext.jsx";
import {updateUserProfile} from "../../services/auth/UserUpdate.jsx";

const EditProfile = () => {
    const {user, profile, fetchProfile} = useAuth();
    const navigate = useNavigate();
    const [formData, setFormData] = useState({
        firstName: "",
        lastName: "",
        phone: "",
        email: "",
    });
    const [errorMessage, setErrorMessage] = useState("");
    const [successMessage, setSuccessMessage] = useState("");
    const [isSubmitting, setIsSubmitting] = useState(false);

    useEffect(() => {
        if (profile) {
            setFormData({
                firstName: profile.first_name ?? "",
                lastName: profile.last_name ?? "",
                phone: profile.phone?.toString() ?? "",
                email: user?.email ?? profile.email ?? "",
            });
        }
    }, [profile, user]);

    const handleChange = (event) => {
        const {name, value} = event.target;
        setFormData((currentValues) => ({
            ...currentValues,
            [name]: value,
        }));
    };

    const handleSubmit = async (event) => {
        event.preventDefault();
        setErrorMessage("");
        setSuccessMessage("");

        const {firstName, lastName, phone, email} = formData;
        if (!firstName || !lastName || !phone || !email) {
            setErrorMessage("Please fill in all fields.");
            return;
        }

        if (!/^\d+$/.test(phone)) {
            setErrorMessage("Phone number must contain digits only.");
            return;
        }

        setIsSubmitting(true);
        const result = await updateUserProfile(user.token, user.id, {
            first_name: firstName,
            last_name: lastName,
            email,
            phone: Number(phone),
        });
        setIsSubmitting(false);

        if (!result.success) {
            setErrorMessage(result.error || "Unable to update your profile right now.");
            return;
        }

        await fetchProfile(user.id, user.token);
        setSuccessMessage("Profile updated successfully.");
        setTimeout(() => navigate("/profile"), 900);
    };

    return (
        <div className={styles["main"]}>
            <div className={styles["authImagePane"]}>
                <img
                    className={styles["authLogo"]}
                    src="/relief-haven-high-resolution-logo.png"
                    alt="Relief Haven Logo"
                />
            </div>

            <section className={styles["registerSection"]}>
                <h1 className={styles["heading"]}>Edit your Relief Haven profile.</h1>
                <div className={styles["disclaimer"]}>Keep your account details current.</div>

                <div className={styles["registerFormContainer"]}>
                    <form className={styles["registerForm"]} onSubmit={handleSubmit}>
                        <div className={styles["names"]}>
                            <input name="firstName" value={formData.firstName} onChange={handleChange} placeholder="Enter first name" />
                            <input name="lastName" value={formData.lastName} onChange={handleChange} placeholder="Enter last name" />
                        </div>
                        <div className={styles["numEmail"]}>
                            <input name="phone" value={formData.phone} onChange={handleChange} placeholder="Enter phone number" />
                            <input name="email" value={formData.email} onChange={handleChange} placeholder="Enter email" />
                        </div>
                        {errorMessage ? <p style={{color: "var(--error, #b3261e)", margin: 0}}>{errorMessage}</p> : null}
                        {successMessage ? <p style={{color: "var(--primary)", margin: 0}}>{successMessage}</p> : null}
                        <button className={styles["submitButton"]} type="submit" disabled={isSubmitting}>
                            {isSubmitting ? "Saving..." : "Save changes"}
                        </button>
                    </form>
                </div>
            </section>
        </div>
    );
};

export default EditProfile;
