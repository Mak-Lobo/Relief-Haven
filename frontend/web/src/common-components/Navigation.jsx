export const Navigation = () => {
    return (
        <div className="nav-block">
            <div className="logo">
                <img className="compass" src="./assets/compass.png" alt="Relief Haven Logo" />
                <h1>Relief Haven</h1>
            </div>
            <nav className="nav">
                <ul>
                    <li><a href="/">Home</a></li>
                    <li><a href="/login">Login</a></li>
                    <li><a href="/register">Register</a></li>
                </ul>
            </nav>
        </div>
    )
}