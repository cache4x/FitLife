using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

public class TreinoController : Controller
{
    private DatabaseContext db;
    public TreinoController(DatabaseContext db) { this.db = db; }

    private string? UserId => HttpContext.Session.GetString("UserId");
    private ActionResult RequireLogin() => RedirectToAction("Entrar", "Autenticacao");

    public ActionResult Index()
    {
        if (UserId == null) return RequireLogin();

        var plans = db.PlanoTreino
            .Where(p => p.UserId == UserId)
            .Include(p => p.Sessions)
            .OrderByDescending(p => p.CreatedAt)
            .ToList();

        return View(plans);
    }

    [HttpGet]
    public ActionResult Criar()
    {
        if (UserId == null) return RequireLogin();
        return View();
    }

    [HttpPost]
    public ActionResult Criar(PlanoTreino form)
    {
        if (UserId == null) return RequireLogin();

        if (string.IsNullOrWhiteSpace(form.Name))
        {
            TempData["Error"] = "O nome do plano é obrigatório.";
            return View(form);
        }

        form.Id        = Guid.NewGuid().ToString();
        form.UserId    = UserId;
        form.CreatedAt = DateTime.UtcNow;

        db.PlanoTreino.Add(form);
        db.SaveChanges();

        TempData["Success"] = $"Plano \"{form.Name}\" criado com sucesso!";
        return RedirectToAction("Detalhes", new { id = form.Id });
    }

    public ActionResult Detalhes(string id)
    {
        if (UserId == null) return RequireLogin();

        var plan = db.PlanoTreino
            .Include(p => p.Sessions)
            .SingleOrDefault(p => p.Id == id && p.UserId == UserId);

        if (plan == null) return NotFound();

        return View(plan);
    }

    public ActionResult Excluir(string id)
    {
        if (UserId == null) return RequireLogin();

        var plan = db.PlanoTreino.SingleOrDefault(p => p.Id == id && p.UserId == UserId);
        if (plan == null) return NotFound();

        var name = plan.Name;
        db.PlanoTreino.Remove(plan);
        db.SaveChanges();

        TempData["Success"] = $"Plano \"{name}\" excluído.";
        return RedirectToAction("Index");
    }
}
