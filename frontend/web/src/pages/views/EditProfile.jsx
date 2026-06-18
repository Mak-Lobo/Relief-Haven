import {useEffect, useState} from "react";
import {useNavigate} from "react-router-dom";
import common from "../../styles/views-common.module.css";
import styles from "../../styles/profile.module.css";
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
        <div className={common.pageFrame}>
            <div className={styles.profileOuter}>
                <h1 className={common.pageTitleCentered}>Edit Profile</h1>
                
                <div className={styles.profileCard}>
                    <form onSubmit={handleSubmit} style={{ display: 'flex', flexDirection: 'column', gap: '20px' }}>
                        <div className={styles.profileGrid}>
                            <div className={styles.profileField}>
                                <span className={common.fieldLabel}>First Name</span>
                                <input className={styles.editInput} name="firstName" value={formData.firstName} onChange={handleChange} placeholder="First name" />
                            </div>
                            <div className={styles.profileField}>
                                <span className={common.fieldLabel}>Last Name</span>
                                <input className={styles.editInput} name="lastName" value={formData.lastName} onChange={handleChange} placeholder="Last name" />
                            </div>
                            <div className={styles.profileField}>
                                <span className={common.fieldLabel}>Phone Number</span>
                                <input className={styles.editInput} name="phone" value={formData.phone} onChange={handleChange} placeholder="Phone number" />
                            </div>
                            <div className={styles.profileField}>
                                <span className={common.fieldLabel}>Email Address</span>
                                <input className={styles.editInput} name="email" value={formData.email} onChange={handleChange} placeholder="Email" />
                            </div>
                        </div>

                        {errorMessage ? <p style={{color: "var(--error, #b3261e)", margin: 0, textAlign: 'center'}}>{errorMessage}</p> : null}
                        {successMessage ? <p style={{color: "var(--primary)", margin: 0, textAlign: 'center'}}>{successMessage}</p> : null}

                        <div className={common.actionRowCentered}>
                            <button className={common.primaryAction} type="submit" disabled={isSubmitting}>
                                <span>{isSubmitting ? "Saving..." : "Save changes"}</span>
                            </button>
                            <button className={common.dangerAction} type="button" onClick={() => navigate("/profile")}>
                                <span>Cancel</span>
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    );
};

export default EditProfile;
