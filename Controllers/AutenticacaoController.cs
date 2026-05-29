using Microsoft.AspNetCore.Mvc;

public class AutenticacaoController : Controller
{
    private DatabaseContext db;
    public AutenticacaoController(DatabaseContext db) { this.db = db; }

    [HttpGet]
    public ActionResult Registrar() => View();

    [HttpPost]
    public ActionResult Registrar(string name, string email, string password, string confirmPassword)
    {
        if (string.IsNullOrWhiteSpace(name) || string.IsNullOrWhiteSpace(email) || string.IsNullOrWhiteSpace(password))
        {
            ViewBag.Error = "Preencha todos os campos.";
            return View();
        }

        if (password != confirmPassword)
        {
            ViewBag.Error = "As senhas não coincidem.";
            return View();
        }

        if (db.Usuario.Any(u => u.Email == email))
        {
            ViewBag.Error = "Este e-mail já está cadastrado.";
            return View();
        }

        var user = new Usuario
        {
            Id        = Guid.NewGuid().ToString(),
            Name      = name,
            Email     = email,
            PasswordHash = BCrypt.Net.BCrypt.HashPassword(password),
            CreatedAt = DateTime.UtcNow
        };

        db.Usuario.Add(user);
        db.SaveChanges();

        HttpContext.Session.SetString("UserId",   user.Id);
        HttpContext.Session.SetString("UserName", user.Name);

        return RedirectToAction("Index", "Inicio");
    }

    [HttpGet]
    public ActionResult Entrar() => View();

    [HttpPost]
    public ActionResult Entrar(string email, string password)
    {
        var user = db.Usuario.SingleOrDefault(u => u.Email == email);

        if (user == null || !BCrypt.Net.BCrypt.Verify(password, user.PasswordHash))
        {
            ViewBag.Error = "E-mail ou senha inválidos.";
            return View();
        }

        HttpContext.Session.SetString("UserId",   user.Id);
        HttpContext.Session.SetString("UserName", user.Name);

        return RedirectToAction("Index", "Inicio");
    }

    public ActionResult Sair()
    {
        HttpContext.Session.Clear();
        return RedirectToAction("Entrar");
    }
}
