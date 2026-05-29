using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

public class AgendaController : Controller
{
    private DatabaseContext db;
    public AgendaController(DatabaseContext db) { this.db = db; }

    private string? UserId => HttpContext.Session.GetString("UserId");
    private ActionResult RequireLogin() => RedirectToAction("Entrar", "Autenticacao");

    public ActionResult Index()
    {
        if (UserId == null) return RequireLogin();

        var schedules = db.Agendamento
            .Include(a => a.WorkoutSession)
            .Include(a => a.Meal)
            .Where(a => a.UserId == UserId)
            .OrderBy(a => a.Date)
            .ToList();

        return View(schedules);
    }

    [HttpGet]
    public ActionResult Criar()
    {
        if (UserId == null) return RequireLogin();

        ViewBag.Sessions = db.SessaoTreino
            .Include(s => s.WorkoutPlan)
            .Where(s => s.WorkoutPlan.UserId == UserId)
            .OrderBy(s => s.WorkoutPlan.Name).ThenBy(s => s.Name)
            .ToList();

        ViewBag.Meals = db.Refeicao
            .Include(r => r.DietPlan)
            .Where(r => r.DietPlan.UserId == UserId)
            .OrderBy(r => r.DietPlan.Name).ThenBy(r => r.Name)
            .ToList();

        return View();
    }

    [HttpPost]
    public ActionResult Criar(Agendamento form)
    {
        if (UserId == null) return RequireLogin();

        if (string.IsNullOrWhiteSpace(form.Title) || string.IsNullOrWhiteSpace(form.Type))
        {
            TempData["Error"] = "Preencha o tipo e o título do agendamento.";
            return RedirectToAction("Criar");
        }

        form.Id        = Guid.NewGuid().ToString();
        form.UserId    = UserId;
        form.Completed = false;

        db.Agendamento.Add(form);
        db.SaveChanges();

        TempData["Success"] = $"\"{form.Title}\" agendado!";
        return RedirectToAction("Index");
    }

    public ActionResult Concluir(string id)
    {
        if (UserId == null) return RequireLogin();

        var item = db.Agendamento.SingleOrDefault(a => a.Id == id && a.UserId == UserId);
        if (item == null) return NotFound();

        item.Completed = true;
        db.SaveChanges();

        TempData["Success"] = $"\"{item.Title}\" marcado como concluído!";
        return RedirectToAction("Index");
    }

    public ActionResult Excluir(string id)
    {
        if (UserId == null) return RequireLogin();

        var item = db.Agendamento.SingleOrDefault(a => a.Id == id && a.UserId == UserId);
        if (item == null) return NotFound();

        var title = item.Title;
        db.Agendamento.Remove(item);
        db.SaveChanges();

        TempData["Success"] = $"\"{title}\" removido da agenda.";
        return RedirectToAction("Index");
    }
}
