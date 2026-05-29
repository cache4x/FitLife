using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

public class DietaController : Controller
{
    private DatabaseContext db;
    public DietaController(DatabaseContext db) { this.db = db; }

    private string? UserId => HttpContext.Session.GetString("UserId");
    private ActionResult RequireLogin() => RedirectToAction("Entrar", "Autenticacao");

    public ActionResult Index()
    {
        if (UserId == null) return RequireLogin();

        var plans = db.PlanoAlimentar
            .Where(p => p.UserId == UserId)
            .Include(p => p.Meals)
            .OrderByDescending(p => p.StartDate)
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
    public ActionResult Criar(PlanoAlimentar form)
    {
        if (UserId == null) return RequireLogin();

        if (string.IsNullOrWhiteSpace(form.Name))
        {
            TempData["Error"] = "O nome do plano é obrigatório.";
            return View(form);
        }

        form.Id        = Guid.NewGuid().ToString();
        form.UserId    = UserId;
        form.StartDate = form.StartDate == default ? DateTime.UtcNow : form.StartDate;

        db.PlanoAlimentar.Add(form);
        db.SaveChanges();

        TempData["Success"] = $"Plano \"{form.Name}\" criado com sucesso!";
        return RedirectToAction("Detalhes", new { id = form.Id });
    }

    public ActionResult Detalhes(string id)
    {
        if (UserId == null) return RequireLogin();

        var plan = db.PlanoAlimentar
            .Include(p => p.Meals)
                .ThenInclude(m => m.Items)
            .SingleOrDefault(p => p.Id == id && p.UserId == UserId);

        if (plan == null) return NotFound();

        return View(plan);
    }

    public ActionResult Excluir(string id)
    {
        if (UserId == null) return RequireLogin();

        var plan = db.PlanoAlimentar.SingleOrDefault(p => p.Id == id && p.UserId == UserId);
        if (plan == null) return NotFound();

        var name = plan.Name;
        db.PlanoAlimentar.Remove(plan);
        db.SaveChanges();

        TempData["Success"] = $"Plano \"{name}\" excluído.";
        return RedirectToAction("Index");
    }
}
